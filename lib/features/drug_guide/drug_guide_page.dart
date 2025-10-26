import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/medication.dart';
import '../../services/medication_service.dart';

/// Tela do Guia de Fármacos
/// Banco de dados local com busca e informações detalhadas de medicamentos
class DrugGuidePage extends StatefulWidget {
  const DrugGuidePage({Key? key}) : super(key: key);
  
  @override
  State<DrugGuidePage> createState() => _DrugGuidePageState();
}

class _DrugGuidePageState extends State<DrugGuidePage> {
  final _searchController = TextEditingController();
  List<Medication> _medications = [];
  List<Medication> _filteredMedications = [];
  String? _selectedCategory;
  String? _selectedSpecies;
  
  @override
  void initState() {
    super.initState();
    _medications = MedicationService.getAllMedications();
    _filteredMedications = _medications;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  /// Filtra medicamentos baseado na busca e filtros
  void _filterMedications() {
    setState(() {
      _filteredMedications = _medications;
      
      // Filtro por busca de texto
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        _filteredMedications = _filteredMedications
            .where((med) =>
                med.name.toLowerCase().contains(query) ||
                med.category.toLowerCase().contains(query))
            .toList();
      }
      
      // Filtro por categoria
      if (_selectedCategory != null) {
        _filteredMedications = _filteredMedications
            .where((med) => med.category == _selectedCategory)
            .toList();
      }
      
      // Filtro por espécie
      if (_selectedSpecies != null) {
        _filteredMedications = _filteredMedications
            .where((med) => med.isCompatibleWithSpecies(_selectedSpecies!))
            .toList();
      }
    });
  }
  
  /// Limpa todos os filtros
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedSpecies = null;
      _filteredMedications = _medications;
    });
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
    final categories = MedicationService.getAllCategories();
    final species = MedicationService.getAllSpecies();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.drugGuideTitle),
        actions: [
          if (_searchController.text.isNotEmpty ||
              _selectedCategory != null ||
              _selectedSpecies != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: 'Limpar filtros',
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Busca
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchDrug,
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
              ),
              onChanged: (_) => _filterMedications(),
            ),
          ),
          
          // Filtros por Categoria e Espécie
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Row(
              children: [
                // Filtro de Categoria
                PopupMenuButton<String>(
                  child: Chip(
                    avatar: const Icon(Icons.category, size: 16),
                    label: Text(_selectedCategory ?? 'Categoria'),
                    deleteIcon: _selectedCategory != null
                        ? const Icon(Icons.close, size: 16)
                        : null,
                    onDeleted: _selectedCategory != null
                        ? () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            _filterMedications();
                          }
                        : null,
                  ),
                  itemBuilder: (context) {
                    return categories.map((category) {
                      return PopupMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList();
                  },
                  onSelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _filterMedications();
                  },
                ),
                
                const SizedBox(width: AppConstants.smallPadding),
                
                // Filtro de Espécie
                PopupMenuButton<String>(
                  child: Chip(
                    avatar: const Icon(Icons.pets, size: 16),
                    label: Text(_selectedSpecies ?? 'Espécie'),
                    deleteIcon: _selectedSpecies != null
                        ? const Icon(Icons.close, size: 16)
                        : null,
                    onDeleted: _selectedSpecies != null
                        ? () {
                            setState(() {
                              _selectedSpecies = null;
                            });
                            _filterMedications();
                          }
                        : null,
                  ),
                  itemBuilder: (context) {
                    return species.map((sp) {
                      return PopupMenuItem<String>(
                        value: sp,
                        child: Text(sp),
                      );
                    }).toList();
                  },
                  onSelected: (sp) {
                    setState(() {
                      _selectedSpecies = sp;
                    });
                    _filterMedications();
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Contador de Resultados
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredMedications.length} medicamento${_filteredMedications.length != 1 ? 's' : ''} encontrado${_filteredMedications.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Lista de Medicamentos
          Expanded(
            child: _filteredMedications.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'Nenhum medicamento encontrado',
                    message: 'Tente ajustar os filtros ou buscar por outro termo',
                    action: _searchController.text.isNotEmpty ||
                            _selectedCategory != null ||
                            _selectedSpecies != null
                        ? ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Limpar Filtros'),
                          )
                        : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: _filteredMedications.length,
                    itemBuilder: (context, index) {
                      final medication = _filteredMedications[index];
                      return _buildMedicationCard(medication);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  /// Card de medicamento na lista
  Widget _buildMedicationCard(Medication medication) {
    return CustomCard(
      onTap: () => _showMedicationDetails(medication),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppColors.primaryBlue,
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
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication.category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Dose e Espécies
          Row(
            children: [
              Expanded(
                child: InfoRow(
                  label: 'Dose:',
                  value: '${medication.minDose}-${medication.maxDose} ${medication.unit}',
                  icon: Icons.science,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Chips de Espécies
          Wrap(
            spacing: AppConstants.smallPadding,
            children: medication.species.map((species) {
              return Chip(
                label: Text(
                  species,
                  style: const TextStyle(fontSize: 12),
                ),
                avatar: const Icon(Icons.pets, size: 16),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
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
    Key? key,
    required this.medication,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              color: AppColors.primaryBlue.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medication,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              medication.category,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Informações de Dosagem
                  InfoRow(
                    label: 'Dose Mínima:',
                    value: '${medication.minDose} ${medication.unit}',
                    icon: Icons.arrow_downward,
                  ),
                  InfoRow(
                    label: 'Dose Máxima:',
                    value: '${medication.maxDose} ${medication.unit}',
                    icon: Icons.arrow_upward,
                  ),
                  
                  const SizedBox(height: AppConstants.smallPadding),
                  
                  // Espécies Compatíveis
                  const Text(
                    'Espécies Compatíveis:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Wrap(
                    spacing: AppConstants.smallPadding,
                    children: medication.species.map((species) {
                      return Chip(
                        label: Text(species),
                        avatar: const Icon(Icons.pets, size: 16),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Descrição
            if (medication.description != null)
              _buildSection(
                context,
                'Descrição',
                medication.description!,
                Icons.info_outline,
                AppColors.info,
              ),
            
            // Indicações
            if (medication.indications != null)
              _buildSection(
                context,
                'Indicações',
                medication.indications!,
                Icons.check_circle_outline,
                AppColors.success,
              ),
            
            // Contraindicações
            if (medication.contraindications != null)
              _buildSection(
                context,
                'Contraindicações',
                medication.contraindications!,
                Icons.cancel_outlined,
                AppColors.error,
              ),
            
            // Precauções
            if (medication.precautions != null)
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
        color: color.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
