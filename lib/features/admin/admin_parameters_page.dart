import 'package:flutter/material.dart';
import '../parametros_guide/models/parametro.dart';
import '../../services/admin_parameter_service.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import 'add_parameter_page.dart';
import 'edit_parameter_page.dart';

/// Dashboard Administrativo para gerenciar parâmetros veterinários
class AdminParametersPage extends StatefulWidget {
  const AdminParametersPage({super.key});

  @override
  State<AdminParametersPage> createState() => _AdminParametersPageState();
}

class _AdminParametersPageState extends State<AdminParametersPage> {
  List<Parametro> _parameters = [];
  List<Parametro> _filteredParameters = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadParameters();
  }
  
  Future<void> _loadParameters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Carregar do CSV local
      final parameters = await AdminParameterService.loadParametersFromCSV();
      setState(() {
        _parameters = parameters;
        _filterParameters();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar parâmetros: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  void _filterParameters() {
    List<Parametro> tempParameters = _parameters;

    if (_searchController.text.isNotEmpty) {
      tempParameters = tempParameters
          .where((p) => p.nome.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredParameters = tempParameters;
    });
  }
  
  void _editParameter(Parametro parameter) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditParameterPage(parameter: parameter),
      ),
    );
    
    if (result == true) {
      _loadParameters();
    }
  }
  
  void _deleteParameter(Parametro parameter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir "${parameter.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    try {
      await AdminParameterService.deleteParameter(parameter.nome);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parâmetro excluído com sucesso'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadParameters();
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
  
  void _addParameter() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddParameterPage(),
      ),
    );
    
    if (result == true) {
      _loadParameters();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = AuthService();
    
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
        title: const Text('Gerenciar Parâmetros'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(_errorMessage),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadParameters,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Barra de Busca
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar parâmetro...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterParameters();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => _filterParameters(),
                      ),
                    ),
                    
                    // Estatísticas
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${_filteredParameters.length}/${_parameters.length}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Lista de Parâmetros
                    Expanded(
                      child: _filteredParameters.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Nenhum parâmetro encontrado'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.defaultPadding),
                              itemCount: _filteredParameters.length,
                              itemBuilder: (context, index) {
                                final parameter = _filteredParameters[index];
                                return _ParameterCard(
                                  parameter: parameter,
                                  onEdit: () => _editParameter(parameter),
                                  onDelete: () => _deleteParameter(parameter),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addParameter,
        tooltip: 'Adicionar Parâmetro',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Widget para exibir card de parâmetro
class _ParameterCard extends StatelessWidget {
  final Parametro parameter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _ParameterCard({
    required this.parameter,
    required this.onEdit,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícone
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.monitor_heart,
              color: AppColors.info,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parameter.nome,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cão: ${parameter.cao}, Gato: ${parameter.gato}, Cavalo: ${parameter.cavalo}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
