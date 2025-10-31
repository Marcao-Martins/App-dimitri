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
  final bool showAppBar;

  const DrugGuidePage({super.key, this.showAppBar = true});

  @override
  State<DrugGuidePage> createState() => _DrugGuidePageState();
}

class _DrugGuidePageState extends State<DrugGuidePage> {
  final _searchController = TextEditingController();
  List<Medication> _medications = [];
  List<Medication> _filteredMedications = [];
  String _selectedFilter = 'Todos';

  // Lista de filtros agora é dinâmica
  List<String> _filters = ['Todos'];

  @override
  void initState() {
    super.initState();
    _medications = MedicationService.getAllMedications();
    // Popula os filtros com as classes únicas dos medicamentos
    _filters.addAll(_getUniqueClasses());
    _filteredMedications = _medications;
    _searchController.addListener(_filterMedications);
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
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Guia de Fármacos'),
            )
          : null,
      body: Column(
        children: [
          // Barra de Busca e Filtro
          Padding(
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

          // Lista de Medicamentos
          Expanded(
            child: _filteredMedications.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'Nenhum medicamento encontrado',
                    message:
                        'Tente ajustar os filtros ou buscar por outro termo.',
                    action:
                        _searchController.text.isNotEmpty || _selectedFilter != 'Todos'
                            ? ElevatedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Limpar Filtros'),
                              )
                            : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
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
        ],
      ),
    );
  }
}

/// Página de Detalhes do Medicamento
class MedicationDetailPage extends StatelessWidget {
  final Medication medication;

  const MedicationDetailPage({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(medication.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            CustomCard(
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
                            Text(
                              medication.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              medication.category,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  InfoRow(
                    label: 'Dose Mínima:',
                    value: '${medication.minDose} ${medication.unit}',
                    icon: Icons.arrow_downward_rounded,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  InfoRow(
                    label: 'Dose Máxima:',
                    value: '${medication.maxDose} ${medication.unit}',
                    icon: Icons.arrow_upward_rounded,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'Espécies Compatíveis:',
                    style: Theme.of(context).textTheme.titleMedium,
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
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Descrição
            if (medication.description != null && medication.description!.isNotEmpty)
              _buildSection(
                context,
                'Descrição',
                medication.description!,
                Icons.info_outline,
                AppColors.info,
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
          ],
        ),
      ),
    );
  }

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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
