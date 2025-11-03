import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medication.dart';
import '../../services/medication_service.dart';
import '../../services/admin_medication_service.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import 'edit_medication_page.dart';
import 'add_medication_page.dart';

/// Dashboard Administrativo para gerenciar o bulário de fármacos
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Medication> _medications = [];
  List<Medication> _filteredMedications = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  final TextEditingController _searchController = TextEditingController();
  String? _selectedClass;
  
  @override
  void initState() {
    super.initState();
    _loadMedications();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      await MedicationService.loadMedicationsFromBackend(forceRefresh: true);
      final medications = MedicationService.getAllMedications();
      
      setState(() {
        _medications = medications;
        _filteredMedications = medications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar medicamentos: $e';
        _isLoading = false;
      });
    }
  }
  
  void _filterMedications() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredMedications = _medications.where((med) {
        final matchesSearch = query.isEmpty ||
            med.name.toLowerCase().contains(query) ||
            (med.description?.toLowerCase().contains(query) ?? false) ||
            (med.tradeName?.toLowerCase().contains(query) ?? false);
        
        final matchesClass = _selectedClass == null ||
            _selectedClass == 'Todas' ||
            med.category == _selectedClass;
        
        return matchesSearch && matchesClass;
      }).toList();
    });
  }
  
  Future<void> _deleteMedication(Medication medication) async {
    // Confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir "${medication.name}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      await AdminMedicationService.deleteMedication(medication.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento excluído com sucesso'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadMedications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    
    // Verifica se é administrador
    if (!authService.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Negado')),
        body: const Center(
          child: Text('Apenas administradores podem acessar esta área.'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _loadMedications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca e filtros
          CustomCard(
            margin: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar medicamentos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterMedications();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => _filterMedications(),
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Filtro por classe
                Row(
                  children: [
                    const Icon(Icons.filter_list, size: 20),
                    const SizedBox(width: 8),
                    const Text('Classe:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedClass,
                        isExpanded: true,
                        hint: const Text('Todas as classes'),
                        items: [
                          const DropdownMenuItem(
                            value: 'Todas',
                            child: Text('Todas as classes'),
                          ),
                          ...MedicationService.getCategories().map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value == 'Todas' ? null : value;
                          });
                          _filterMedications();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Estatísticas
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.medication,
                    label: 'Total',
                    value: _medications.length.toString(),
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _StatCard(
                    icon: Icons.filter_alt,
                    label: 'Filtrados',
                    value: _filteredMedications.length.toString(),
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _StatCard(
                    icon: Icons.category,
                    label: 'Classes',
                    value: MedicationService.getCategories().length.toString(),
                    color: AppColors.categoryPurple,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Lista de medicamentos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            FilledButton.icon(
                              onPressed: _loadMedications,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : _filteredMedications.isEmpty
                        ? const Center(
                            child: Text('Nenhum medicamento encontrado'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultPadding,
                            ),
                            itemCount: _filteredMedications.length,
                            itemBuilder: (context, index) {
                              final medication = _filteredMedications[index];
                              return _MedicationListItem(
                                medication: medication,
                                onEdit: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditMedicationPage(
                                        medication: medication,
                                      ),
                                    ),
                                  );
                                  _loadMedications();
                                },
                                onDelete: () => _deleteMedication(medication),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMedicationPage(),
            ),
          );
          _loadMedications();
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Medicamento'),
      ),
    );
  }
}

/// Card de estatística
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

/// Item da lista de medicamentos
class _MedicationListItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _MedicationListItem({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Row(
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: AppColors.primaryTeal,
              size: 28,
            ),
          ),
          
          const SizedBox(width: AppConstants.defaultPadding),
          
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medication.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.categoryPurple,
                  ),
                ),
                if (medication.tradeName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    medication.tradeName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Ações
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                color: AppColors.info,
                tooltip: 'Editar',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: AppColors.error,
                tooltip: 'Excluir',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
