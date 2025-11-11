import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/modern_widgets.dart';
import '../../models/medication.dart';
import '../../services/medication_service.dart';

/// Tela do Guia de Fármacos - Design Moderno
/// Banco de dados local com busca e informações detalhadas de medicamentos
class DrugGuidePage extends StatefulWidget {
  const DrugGuidePage({super.key});

  @override
  State<DrugGuidePage> createState() => _DrugGuidePageState();
}

class _DrugGuidePageState extends State<DrugGuidePage> {
  final _searchController = TextEditingController();
  List<Medication> _medications = [];
  List<Medication> _filteredMedications = [];
  String _selectedFilter = 'Todos';
  bool _isLoading = false;
  String? _errorMessage;

  // Lista de filtros agora é dinâmica
  List<String> _filters = ['Todos'];

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _searchController.addListener(_filterMedications);
  }
  
  /// Carrega medicamentos do backend
  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Tenta carregar do backend
      await MedicationService.loadMedicationsFromBackend();
      setState(() {
        _medications = MedicationService.getAllMedications();
        _filters = ['Todos', ..._getUniqueClasses()];
        _filteredMedications = _medications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar medicamentos: $e';
        _isLoading = false;
      });
    }
  }
  
  /// Força refresh dos dados
  Future<void> _refreshMedications() async {
    try {
      await MedicationService.loadMedicationsFromBackend(forceRefresh: true);
      setState(() {
        _medications = MedicationService.getAllMedications();
        _filters = ['Todos', ..._getUniqueClasses()];
        _filterMedications();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamentos atualizados!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMedications);
    _searchController.dispose();
    super.dispose();
  }

  /// Extrai classes únicas da lista de medicamentos
  List<String> _getUniqueClasses() {
    final classes = _medications.map((med) => med.category).toSet().toList();
    classes.sort();
    return classes;
  }

  /// Filtra medicamentos baseado na busca e filtro selecionado
  void _filterMedications() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      var filtered = _medications.where((med) {
        final nameMatch = med.name.toLowerCase().contains(query);
        final categoryMatch = med.category.toLowerCase().contains(query);
        return nameMatch || categoryMatch;
      }).toList();

      if (_selectedFilter != 'Todos') {
        filtered = filtered
            .where((med) => med.category.contains(_selectedFilter))
            .toList();
      }
      _filteredMedications = filtered;
    });
  }

  /// Limpa todos os filtros
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedFilter = 'Todos';
      // A chamada a _filterMedications() é desnecessária aqui porque
      // o listener do _searchController já fará isso.
    });
  }

  /// Retorna a cor do ícone baseado na categoria
  Color _getIconColor(String category) {
    if (category.contains('Anestésico')) return AppColors.primaryTeal;
    if (category.contains('Analgésico')) return AppColors.categoryOrange;
    if (category.contains('Sedativo')) return AppColors.categoryPurple;
    if (category.contains('Bloqueador')) return AppColors.categoryBlue;
    return AppColors.categoryGreen;
  }

  /// Retorna a tag do medicamento
  String _getTag(Medication med) {
    if (med.category.contains('Controlado')) return 'CTRL';
    if (med.isCompatibleWithSpecies('Canino') &&
        med.isCompatibleWithSpecies('Felino')) return 'VET';
    return 'PA';
  }

  /// Retorna a cor da tag
  Color _getTagColor(String tag) {
    switch (tag) {
      case 'VET':
        return AppColors.tagVet;
      case 'CTRL':
        return AppColors.tagControlled;
      case 'PA':
        return AppColors.tagPA;
      default:
        return AppColors.primaryTeal;
    }
  }

  /// Exibe detalhes completos do medicamento
  void _showMedicationDetails(Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailPage(medication: medication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Guia de Fármacos'),
        actions: [
          // Botão de refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshMedications,
            tooltip: 'Atualizar dados do servidor',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando medicamentos do servidor...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadMedications,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Barra de Busca e Filtro
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Column(
                          children: [
                            ModernSearchBar(
                              controller: _searchController,
                              hintText: AppStrings.searchDrug,
                              onChanged: (value) {}, // Listener já faz o trabalho
                            ),
                            const SizedBox(height: 12),
                            // Dropdown de Filtro por Classe - SEM LABEL e com opções dinâmicas
                            DropdownButtonFormField<String>(
                              value: _selectedFilter,
                              items: _filters.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedFilter = newValue!;
                              });
                              _filterMedications();
                            },
                            decoration: InputDecoration(
                              // labelText removido para um design mais limpo
                              prefixIcon: const Icon(Icons.filter_list),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),

                    // Lista de Medicamentos
                    Expanded(
                      child: _filteredMedications.isEmpty
                          ? EmptyState(
                              icon: Icons.search_off,
                              title: _medications.isEmpty
                                  ? 'Nenhum medicamento carregado'
                                  : 'Nenhum medicamento encontrado',
                              message: _medications.isEmpty
                                  ? 'Clique no botão de atualizar para carregar do servidor'
                                  : 'Tente ajustar os filtros ou buscar por outro termo.',
                              action: _searchController.text.isNotEmpty ||
                                      _selectedFilter != 'Todos'
                                  ? ElevatedButton.icon(
                                      onPressed: _clearFilters,
                                      icon: const Icon(Icons.clear_all),
                                      label: const Text('Limpar Filtros'),
                                    )
                                  : null,
                            )
                          : RefreshIndicator(
                              onRefresh: _refreshMedications,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.defaultPadding),
                                itemCount: _filteredMedications.length,
                                itemBuilder: (context, index) {
                                  final medication = _filteredMedications[index];
                                  return MedicationListItem(
                                    icon: Icons.medication_outlined,
                                    iconColor: _getIconColor(medication.category),
                                    title: medication.name,
                                    subtitle: medication.category,
                                    tag: _getTag(medication),
                                    tagColor: _getTagColor(_getTag(medication)),
                                    onTap: () => _showMedicationDetails(medication),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}

/// Página de Detalhes do Medicamento - Layout Expandido
class MedicationDetailPage extends StatelessWidget {
  final Medication medication;

  const MedicationDetailPage({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(medication.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho Principal
            _buildHeader(context),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Classe Farmacológica
            _buildInfoCard(
              context,
              'Classe Farmacológica',
              medication.category,
              Icons.category_outlined,
              AppColors.categoryPurple,
            ),
            
            // Nome Comercial
            if (medication.tradeName != null && medication.tradeName!.isNotEmpty)
              _buildInfoCard(
                context,
                'Nome Comercial',
                medication.tradeName!,
                Icons.shopping_bag_outlined,
                AppColors.categoryBlue,
              ),
            
            // Mecanismo de Ação
            if (medication.mechanismOfAction != null && medication.mechanismOfAction!.isNotEmpty)
              _buildSection(
                context,
                'Mecanismo de Ação',
                medication.mechanismOfAction!,
                Icons.science_outlined,
                AppColors.info,
              ),
            
            // Posologia - Cães
            if (medication.dogDosage != null && medication.dogDosage!.isNotEmpty)
              _buildDosageCard(
                context,
                'Posologia em Cães',
                medication.dogDosage!,
                Icons.pets,
                AppColors.categoryOrange,
              ),
            
            // Posologia - Gatos
            if (medication.catDosage != null && medication.catDosage!.isNotEmpty)
              _buildDosageCard(
                context,
                'Posologia em Gatos',
                medication.catDosage!,
                Icons.pets,
                AppColors.primaryTeal,
              ),
            
            // Infusão Venosa Contínua (CRI/IVC)
            if (medication.cri != null && medication.cri!.isNotEmpty)
              _buildSection(
                context,
                'Infusão Venosa Contínua (IVC)',
                medication.cri!,
                Icons.water_drop_outlined,
                AppColors.categoryBlue,
              ),
            
            // Comentários
            if (medication.comments != null && medication.comments!.isNotEmpty)
              _buildSection(
                context,
                'Comentários e Observações',
                medication.comments!,
                Icons.comment_outlined,
                AppColors.warning,
              ),
            
            // Indicações
            if (medication.indications != null && medication.indications!.isNotEmpty)
              _buildSection(
                context,
                'Indicações',
                medication.indications!,
                Icons.check_circle_outline,
                AppColors.success,
              ),
            
            // Contraindicações
            if (medication.contraindications != null && medication.contraindications!.isNotEmpty)
              _buildSection(
                context,
                'Contraindicações',
                medication.contraindications!,
                Icons.cancel_outlined,
                AppColors.error,
              ),
            
            // Precauções
            if (medication.precautions != null && medication.precautions!.isNotEmpty)
              _buildSection(
                context,
                'Precauções',
                medication.precautions!,
                Icons.warning_amber_outlined,
                AppColors.warning,
              ),
            
            // Referências Bibliográficas
            if (medication.references != null && medication.references!.isNotEmpty)
              _buildReferencesCard(context),
            
            const SizedBox(height: AppConstants.defaultPadding),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho com título e informações básicas
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      color: AppColors.primaryTeal.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título (description) se disponível
                    if (medication.description != null && medication.description!.isNotEmpty)
                      Text(
                        medication.description!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      medication.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Doses de referência
          Row(
            children: [
              Expanded(
                child: _buildDoseChip(
                  context,
                  'Min',
                  '${medication.minDose} ${medication.unit}',
                  Icons.arrow_downward_rounded,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDoseChip(
                  context,
                  'Max',
                  '${medication.maxDose} ${medication.unit}',
                  Icons.arrow_upward_rounded,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Espécies compatíveis
          Text(
            'Espécies:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: medication.species.map((species) {
              return Chip(
                label: Text(species),
                avatar: const Icon(Icons.pets, size: 16),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Card de informação simples
  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: CustomCard(
        color: color.withValues(alpha: 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de dosagem com destaque
  Widget _buildDosageCard(
    BuildContext context,
    String title,
    String dosage,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: CustomCard(
        color: color.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                dosage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção expandida com conteúdo longo
  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: CustomCard(
        color: color.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de referências bibliográficas
  Widget _buildReferencesCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: CustomCard(
        color: AppColors.info.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_outlined, color: AppColors.info),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Referências Bibliográficas',
                  style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Text(
                medication.references!,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chip de dose
  Widget _buildDoseChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
