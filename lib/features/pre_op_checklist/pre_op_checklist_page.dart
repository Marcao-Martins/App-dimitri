import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/utils/format_utils.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';

/// Tela do Checklist Pré-Operatório
/// Interface interativa para verificação sistemática antes da anestesia
class PreOpChecklistPage extends StatefulWidget {
  final bool showAppBar;

  const PreOpChecklistPage({super.key, this.showAppBar = true});
  
  @override
  State<PreOpChecklistPage> createState() => _PreOpChecklistPageState();
}

class _PreOpChecklistPageState extends State<PreOpChecklistPage> {
  List<ChecklistItem> _items = [];
  String? _selectedCategory;
  String _selectedAsaClassification = AppConstants.asaClassifications[0];
  DateTime? _fastingStartTime;
  Timer? _timer;
  Duration _fastingDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _items = ChecklistService.getDefaultChecklistItems();
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  /// Inicia o timer de jejum
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_fastingStartTime != null) {
        setState(() {
          _fastingDuration = DateTime.now().difference(_fastingStartTime!);
        });
      }
    });
  }
  
  /// Alterna o estado de um item do checklist
  void _toggleItem(ChecklistItem item) {
    setState(() {
      item.toggle();
    });
  }
  
  /// Reseta o checklist
  void _resetChecklist() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmReset),
        content: const Text('Todos os itens serão desmarcados. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items = ChecklistService.getDefaultChecklistItems();
                _fastingStartTime = null;
                _fastingDuration = Duration.zero;
              });
              Navigator.pop(context);
              _showSuccess('Checklist resetado com sucesso');
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
  
  /// Configura o timer de jejum
  void _setFastingTimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Timer de Jejum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quando o animal iniciou o jejum?'),
            const SizedBox(height: AppConstants.defaultPadding),
            ListTile(
              title: const Text('Agora'),
              leading: Radio<String>(
                value: 'now',
                groupValue: 'time',
                onChanged: (_) {
                  setState(() {
                    _fastingStartTime = DateTime.now();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Escolher horário'),
              leading: Radio<String>(
                value: 'custom',
                groupValue: null,
                onChanged: null,
              ),
              onTap: () async {
                Navigator.pop(context);
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now(),
                );
                
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  
                  if (time != null) {
                    setState(() {
                      _fastingStartTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Filtra itens por categoria
  List<ChecklistItem> get _filteredItems {
    if (_selectedCategory == null) return _items;
    return _items.where((item) => item.category == _selectedCategory).toList();
  }
  
  /// Calcula o progresso do checklist
  double get _progress {
    if (_items.isEmpty) return 0.0;
    final completed = _items.where((item) => item.isCompleted).length;
    return completed / _items.length;
  }
  
  /// Verifica se todos os itens críticos foram completados
  bool get _criticalItemsCompleted {
    final critical = _items.where((item) => item.isCritical);
    return critical.every((item) => item.isCompleted);
  }
  
  /// Exibe mensagem de sucesso
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: AppConstants.snackBarDuration,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final categories = ChecklistService.getCategories();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(AppStrings.checklistTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  onPressed: _resetChecklist,
                  tooltip: AppStrings.resetChecklist,
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    // TODO: Implementar exportação para PDF
                    _showSuccess('Funcionalidade de exportação em desenvolvimento');
                  },
                  tooltip: AppStrings.exportPdf,
                ),
              ],
            )
      : null,
      body: Column(
        children: [
          // Cabeçalho com progresso e ASA
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra de Progresso
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progresso',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                FormatUtils.formatPercentage(_progress),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.smallPadding),
                          LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Theme.of(context).dividerColor,
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    StatusBadge(
                      text: _criticalItemsCompleted ? 'OK' : 'Pendente',
                      color: _criticalItemsCompleted
                          ? AppColors.success
                          : AppColors.warning,
                      icon: _criticalItemsCompleted
                          ? Icons.check_circle
                          : Icons.warning,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Classificação ASA e Timer de Jejum
                Row(
                  children: [
                    // ASA
                    Expanded(
                      child: CustomCard(
                        padding: const EdgeInsets.all(AppConstants.smallPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.assessment, size: 16),
                                SizedBox(width: AppConstants.smallPadding),
                                Text(
                                  'ASA',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
                              value: _selectedAsaClassification,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: AppConstants.asaClassifications.map((asa) {
                                return DropdownMenuItem(
                                  value: asa,
                                  child: Text(
                                    asa,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAsaClassification = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppConstants.smallPadding),
                    
                    // Timer de Jejum
                    Expanded(
                      child: CustomCard(
                        padding: const EdgeInsets.all(AppConstants.smallPadding),
                        onTap: _setFastingTimer,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.timer, size: 16),
                                SizedBox(width: AppConstants.smallPadding),
                                Text(
                                  'Jejum',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            Text(
                              _fastingStartTime == null
                                  ? 'Não iniciado'
                                  : FormatUtils.formatDuration(_fastingDuration),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _fastingDuration.inHours >= 8
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filtro por categoria
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.smallPadding),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('Todas', null),
                ...categories.map((category) => _buildCategoryChip(category, category)),
              ],
            ),
          ),
          
          // Lista de itens do checklist
          Expanded(
            child: _filteredItems.isEmpty
                ? EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'Nenhum item nesta categoria',
                    message: 'Selecione outra categoria para ver os itens',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildChecklistItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  /// Chip de filtro de categoria
  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  /// Item do checklist
  Widget _buildChecklistItem(ChecklistItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: CheckboxListTile(
        value: item.isCompleted,
        onChanged: (_) => _toggleItem(item),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            if (item.isCritical)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CRÍTICO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppConstants.smallPadding),
          child: Text(
            item.description,
            style: TextStyle(
              decoration: item.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: _getCategoryColor(item.category).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: _getCategoryColor(item.category),
          ),
        ),
        activeColor: AppColors.success,
      ),
    );
  }
  
  /// Retorna a cor da categoria
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Paciente':
        return AppColors.primaryTeal;
      case 'Equipamento':
        return AppColors.accentTeal;
      case 'Medicação':
        return Colors.purple;
      case 'Procedimento':
        return Colors.orange;
      case 'Segurança':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
  
  /// Retorna o ícone da categoria
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Paciente':
        return Icons.pets;
      case 'Equipamento':
        return Icons.medical_services;
      case 'Medicação':
        return Icons.medication;
      case 'Procedimento':
        return Icons.healing;
      case 'Segurança':
        return Icons.security;
      default:
        return Icons.check_circle_outline;
    }
  }
}
