import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../models/medication.dart';
import '../../models/dose_calculation.dart';
import '../../services/medication_service.dart';
import 'oxygen_autonomy_calculator_page.dart';
import '../unit_converter/unit_converter_page.dart';

/// Tela da Calculadora de Doses
/// Permite calcular doses de medicamentos baseado no peso e espécie do animal
class DoseCalculatorPage extends StatefulWidget {
  final bool showAppBar;

  const DoseCalculatorPage({super.key, this.showAppBar = true});
  
  @override
  State<DoseCalculatorPage> createState() => _DoseCalculatorPageState();
}

class _DoseCalculatorPageState extends State<DoseCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  
  String? _selectedSpecies;
  Medication? _selectedMedication;
  List<Medication> _availableMedications = [];
  DoseCalculation? _lastCalculation;
  
  @override
  void initState() {
    super.initState();
    _availableMedications = MedicationService.getAllMedications();
  }
  
  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
  
  /// Filtra medicamentos quando a espécie é selecionada
  void _onSpeciesChanged(String? species) {
    setState(() {
      _selectedSpecies = species;
      _selectedMedication = null;
      
      if (species != null) {
        _availableMedications = MedicationService.filterBySpecies(species);
      } else {
        _availableMedications = MedicationService.getAllMedications();
      }
    });
  }
  
  /// Calcula a dose do medicamento
  void _calculateDose() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedSpecies == null) {
      _showError(AppStrings.errorSelectSpecies);
      return;
    }
    
    if (_selectedMedication == null) {
      _showError(AppStrings.errorSelectMedication);
      return;
    }
    
    final weight = double.parse(_weightController.text.replaceAll(',', '.'));
    final calculatedDose = _selectedMedication!.calculateDose(weight);
    final isSafe = _selectedMedication!.isDoseSafe(calculatedDose, weight);
    final doseRange = _selectedMedication!.getSafeDoseRange(weight);
    
    setState(() {
      _lastCalculation = DoseCalculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        medicationName: _selectedMedication!.name,
        weightKg: weight,
        species: _selectedSpecies!,
        calculatedDose: calculatedDose,
        unit: _selectedMedication!.unit,
        wasSafe: isSafe,
      );
    });
    
    // Exibe diálogo com resultado
    _showResultDialog(calculatedDose, doseRange, isSafe);
  }
  
  /// Exibe diálogo com o resultado do cálculo
  void _showResultDialog(
    double dose,
    Map<String, double> doseRange,
    bool isSafe,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSafe ? Icons.check_circle : Icons.warning,
              color: isSafe ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            const Text('Resultado do Cálculo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(
              label: 'Medicamento:',
              value: _selectedMedication!.name,
              icon: Icons.medication,
            ),
            InfoRow(
              label: 'Espécie:',
              value: _selectedSpecies!,
              icon: Icons.pets,
            ),
            InfoRow(
              label: 'Peso:',
              value: FormatUtils.formatWeight(
                double.parse(_weightController.text.replaceAll(',', '.')),
              ),
              icon: Icons.monitor_weight,
            ),
            const Divider(height: AppConstants.defaultPadding * 2),
            InfoRow(
              label: 'Dose Calculada:',
              value: FormatUtils.formatDose(dose, _selectedMedication!.unit),
              icon: Icons.calculate,
            ),
            InfoRow(
              label: 'Faixa Segura:',
              value: '${FormatUtils.formatDouble(doseRange['min']!)} - '
                     '${FormatUtils.formatDouble(doseRange['max']!)} '
                     '${_selectedMedication!.unit}',
              icon: Icons.safety_check,
            ),
            if (!isSafe) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(
                        'Atenção: Dose fora da faixa recomendada!',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMedicationInfo();
            },
            child: const Text('Ver Informações'),
          ),
        ],
      ),
    );
  }
  
  /// Exibe informações detalhadas do medicamento
  void _showMedicationInfo() {
    if (_selectedMedication == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedMedication!.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(
                'Categoria',
                _selectedMedication!.category,
                Icons.category,
              ),
              if (_selectedMedication!.description != null)
                _buildInfoSection(
                  'Descrição',
                  _selectedMedication!.description!,
                  Icons.info,
                ),
              if (_selectedMedication!.indications != null)
                _buildInfoSection(
                  'Indicações',
                  _selectedMedication!.indications!,
                  Icons.check_circle,
                ),
              if (_selectedMedication!.contraindications != null)
                _buildInfoSection(
                  'Contraindicações',
                  _selectedMedication!.contraindications!,
                  Icons.cancel,
                ),
              if (_selectedMedication!.precautions != null)
                _buildInfoSection(
                  'Precauções',
                  _selectedMedication!.precautions!,
                  Icons.warning_amber,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.bodyFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            content,
            style: const TextStyle(fontSize: AppConstants.captionFontSize),
          ),
        ],
      ),
    );
  }
  
  /// Limpa o formulário
  void _clearForm() {
    setState(() {
      _weightController.clear();
      _selectedSpecies = null;
      _selectedMedication = null;
      _lastCalculation = null;
      _availableMedications = MedicationService.getAllMedications();
    });
  }
  
  /// Exibe mensagem de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: AppConstants.snackBarDuration,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final species = MedicationService.getAllSpecies();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: widget.showAppBar
          ? AppBar(
              title: const Text(AppStrings.calculatorTitle),
              actions: [
                // Botão para o conversor de unidades
                IconButton(
                  icon: const Icon(Icons.swap_vert_circle_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnitConverterPage(),
                      ),
                    );
                  },
                  tooltip: 'Conversor de Unidades',
                ),
                // Botão para a calculadora de O2
                IconButton(
                  icon: const Icon(Icons.propane_tank_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OxygenAutonomyCalculatorPage(),
                      ),
                    );
                  },
                  tooltip: 'Autonomia do Cilindro de O₂',
                ),
                if (_weightController.text.isNotEmpty ||
                    _selectedSpecies != null ||
                    _selectedMedication != null)
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: _clearForm,
                    tooltip: AppStrings.clear,
                  ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informações do Animal
              SectionHeader(
                title: 'Informações do Animal',
                icon: Icons.pets,
              ),
              
              CustomCard(
                child: Column(
                  children: [
                    CustomTextField(
                      label: AppStrings.weightLabel,
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: ValidationUtils.validateWeight,
                      prefixIcon: Icons.monitor_weight,
                      hint: 'Ex: 15.5',
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    CustomDropdown<String>(
                      label: AppStrings.speciesLabel,
                      value: _selectedSpecies,
                      items: species,
                      itemLabel: (s) => s,
                      onChanged: _onSpeciesChanged,
                      prefixIcon: Icons.pets,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Seleção de Medicamento
              SectionHeader(
                title: 'Medicamento',
                icon: Icons.medication,
              ),
              
              CustomCard(
                child: CustomDropdown<Medication>(
                  label: AppStrings.medicationLabel,
                  value: _selectedMedication,
                  items: _availableMedications,
                  itemLabel: (med) => '${med.name} (${med.category})',
                  onChanged: (med) => setState(() => _selectedMedication = med),
                  prefixIcon: Icons.medication,
                ),
              ),
              
              // Informação do medicamento selecionado
              if (_selectedMedication != null) ...[
                const SizedBox(height: AppConstants.defaultPadding),
                CustomCard(
                  color: AppColors.info.withValues(alpha: 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: AppConstants.smallPadding),
                          Text(
                            'Informações do Medicamento',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      InfoRow(
                        label: 'Categoria:',
                        value: _selectedMedication!.category,
                      ),
                      InfoRow(
                        label: 'Dose:',
                        value: '${_selectedMedication!.minDose}-'
                               '${_selectedMedication!.maxDose} '
                               '${_selectedMedication!.unit}',
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      TextButton.icon(
                        onPressed: _showMedicationInfo,
                        icon: const Icon(Icons.read_more),
                        label: const Text('Ver Detalhes Completos'),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Botão de Calcular
              PrimaryButton(
                text: AppStrings.calculateButton,
                icon: Icons.calculate,
                onPressed: _calculateDose,
              ),
              
              // Último Cálculo
              if (_lastCalculation != null) ...[
                const SizedBox(height: AppConstants.largePadding),
                SectionHeader(
                  title: 'Último Cálculo',
                  icon: Icons.history,
                ),
                CustomCard(
                  color: _lastCalculation!.wasSafe
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _lastCalculation!.medicationName,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          StatusBadge(
                            text: _lastCalculation!.wasSafe ? 'Seguro' : 'Atenção',
                            color: _lastCalculation!.wasSafe
                                ? AppColors.success
                                : AppColors.warning,
                            icon: _lastCalculation!.wasSafe
                                ? Icons.check_circle
                                : Icons.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      InfoRow(
                        label: 'Dose Calculada:',
                        value: FormatUtils.formatDose(
                          _lastCalculation!.calculatedDose,
                          _lastCalculation!.unit,
                        ),
                      ),
                      InfoRow(
                        label: 'Peso:',
                        value: FormatUtils.formatWeight(_lastCalculation!.weightKg),
                      ),
                      InfoRow(
                        label: 'Espécie:',
                        value: _lastCalculation!.species,
                      ),
                      InfoRow(
                        label: 'Data/Hora:',
                        value: _lastCalculation!.getFormattedDate(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
