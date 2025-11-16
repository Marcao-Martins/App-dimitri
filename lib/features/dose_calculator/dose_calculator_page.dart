import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'oxygen_autonomy_calculator_page.dart';
import '../unit_converter/unit_converter_page.dart';
import '../fluidotherapy/fluidotherapy_page.dart';
import '../transfusion/transfusion_page.dart';
import '../../models/medication.dart';
import '../../services/medication_service.dart';

/// Modelo simplificado para histórico de cálculos
class CalculationHistory {
  final GlobalKey key = GlobalKey();
  final DateTime timestamp;
  final double weight;
  final double dose;
  final String doseUnit;
  final double concentration;
  final String concentrationUnit;
  final double volume;

  CalculationHistory({
    required this.timestamp,
    required this.weight,
    required this.dose,
    required this.doseUnit,
    required this.concentration,
    required this.concentrationUnit,
    required this.volume,
  });
}

/// Tela da Calculadora de Doses Simplificada
/// Calcula o volume necessário baseado em peso, dose e concentração
class DoseCalculatorPage extends StatefulWidget {
  const DoseCalculatorPage({super.key});
  
  @override
  State<DoseCalculatorPage> createState() => _DoseCalculatorPageState();
}

class _DoseCalculatorPageState extends State<DoseCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _doseController = TextEditingController();
  final _concentrationController = TextEditingController();
  
  String _doseUnit = 'mg/kg';
  String _concentrationUnit = 'mg/ml';
  double? _calculatedVolume;
  final List<CalculationHistory> _history = [];
  
  // Campos para integração com fármacos
  List<Medication> _medications = [];
  List<Medication> _filteredMedications = [];
  Medication? _selectedMedication;
  final _medicationSearchController = TextEditingController();
  bool _isLoadingMedications = false;
  bool _showMedicationDropdown = false;
  
  @override
  void initState() {
    super.initState();
    // Calcular em tempo real
    _weightController.addListener(_updateLiveCalculation);
    _doseController.addListener(_updateLiveCalculation);
    _concentrationController.addListener(_updateLiveCalculation);
    
    // Carregar medicamentos
    _loadMedications();
  }
  
  @override
  void dispose() {
    _weightController.dispose();
    _doseController.dispose();
    _concentrationController.dispose();
    _medicationSearchController.dispose();
    super.dispose();
  }
  
  /// Carrega medicamentos do serviço
  Future<void> _loadMedications() async {
    setState(() {
      _isLoadingMedications = true;
    });
    
    try {
      await MedicationService.loadMedicationsFromBackend();
      setState(() {
        _medications = MedicationService.getAllMedications();
        _filteredMedications = _medications;
        _isLoadingMedications = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedications = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar fármacos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Filtra medicamentos com base na busca
  void _filterMedications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedications = _medications;
      } else {
        _filteredMedications = _medications
            .where((med) => 
                med.name.toLowerCase().contains(query.toLowerCase()) ||
                (med.tradeName?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }
  
  /// Seleciona um fármaco e preenche os campos
  void _selectMedication(Medication medication) {
    setState(() {
      _selectedMedication = medication;
      _showMedicationDropdown = false;
      _medicationSearchController.text = medication.name;
      
      // NÃO preenche a dose automaticamente - deixa o usuário escolher
      // Apenas atualiza a validação
      _updateLiveCalculation();
    });
    
    // Mostra informações do fármaco selecionado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${medication.name} selecionado',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Faixa de dose recomendada: ${medication.minDose}-${medication.maxDose} ${medication.unit}',
              style: const TextStyle(fontSize: 12),
            ),
            if (medication.tradeName != null)
              Text(
                'Nome comercial: ${medication.tradeName}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Limpa seleção de fármaco
  void _clearMedicationSelection() {
    setState(() {
      _selectedMedication = null;
      _medicationSearchController.clear();
      _filteredMedications = _medications;
    });
  }
  
  /// Converte dose para mcg/kg
  double _convertDoseToMcg(double dose) {
    if (_doseUnit == 'mg/kg') {
      return dose * 1000; // mg para mcg
    }
    return dose; // já está em mcg/kg
  }
  
  /// Converte concentração para mcg/ml
  double _convertConcentrationToMcg(double concentration) {
    if (_concentrationUnit == 'mg/ml') {
      return concentration * 1000; // mg para mcg
    }
    return concentration; // já está em mcg/ml
  }
  
  /// Calcula o volume necessário (apenas para exibição em tempo real)
  void _updateLiveCalculation() {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final dose = double.tryParse(_doseController.text.replaceAll(',', '.'));
    final concentration = double.tryParse(_concentrationController.text.replaceAll(',', '.'));
    
    if (weight != null && weight > 0 &&
        dose != null && dose > 0 &&
        concentration != null && concentration > 0) {
      // Converter tudo para mcg
      final doseInMcg = _convertDoseToMcg(dose);
      final concentrationInMcg = _convertConcentrationToMcg(concentration);
      
      setState(() {
        // Fórmula: Volume (ml) = (Peso × Dose) / Concentração
        _calculatedVolume = (weight * doseInMcg) / concentrationInMcg;
      });
    } else {
      setState(() {
        _calculatedVolume = null;
      });
    }
  }

  /// Salva o cálculo atual no histórico
  void _saveCalculationToHistory() {
    if (_calculatedVolume == null) return;

    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final dose = double.tryParse(_doseController.text.replaceAll(',', '.'));
    final concentration = double.tryParse(_concentrationController.text.replaceAll(',', '.'));

    if (weight == null || dose == null || concentration == null) return;

    setState(() {
      _history.insert(0, CalculationHistory(
        timestamp: DateTime.now(),
        weight: weight,
        dose: dose,
        doseUnit: _doseUnit,
        concentration: concentration,
        concentrationUnit: _concentrationUnit,
        volume: _calculatedVolume!,
      ));
      
      // Limitar histórico a 10 itens
      if (_history.length > 10) {
        _history.removeLast();
      }
    });

    // Feedback para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cálculo salvo no histórico!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VER',
          onPressed: () {
            // Scroll para o histórico
            Scrollable.ensureVisible(
              _history.first.key.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
  
  /// Limpa todos os campos
  void _clearFields() {
    _weightController.clear();
    _doseController.clear();
    _concentrationController.clear();
    setState(() {
      _calculatedVolume = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Fecha o dropdown quando clicar fora
        if (_showMedicationDropdown) {
          setState(() {
            _showMedicationDropdown = false;
          });
        }
        // Remove o foco dos campos de texto
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Calculadora de Doses'),
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
          // Botão para a calculadora de Fluidoterapia
          IconButton(
            icon: const Icon(Icons.water_drop),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FluidotherapyPage(),
                ),
              );
            },
            tooltip: 'Calculadora de Fluidoterapia',
          ),
          // Botão para a calculadora de Transfusão
          IconButton(
            icon: const Icon(Icons.bloodtype),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransfusionPage(),
                ),
              );
            },
            tooltip: 'Calculadora de Transfusão Sanguínea',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Seleção de Fármaco (Opcional)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Referência de Fármaco (Opcional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecione um fármaco do bulário para visualizar a faixa de dose '
                        'recomendada. Você mantém total controle sobre os valores inseridos.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Campo de busca de fármaco
                      TextFormField(
                        controller: _medicationSearchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar Fármaco',
                          hintText: 'Digite o nome do fármaco',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _selectedMedication != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearMedicationSelection,
                                  tooltip: 'Limpar seleção',
                                )
                              : null,
                        ),
                        onChanged: _filterMedications,
                        onTap: () {
                          setState(() {
                            _showMedicationDropdown = true;
                          });
                        },
                      ),
                      
                      // Lista de sugestões
                      if (_showMedicationDropdown && _filteredMedications.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredMedications.length,
                            itemBuilder: (context, index) {
                              final medication = _filteredMedications[index];
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.medication,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                title: Text(
                                  medication.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${medication.minDose}-${medication.maxDose} ${medication.unit}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onTap: () => _selectMedication(medication),
                              );
                            },
                          ),
                        ),
                      
                      // Informações do fármaco selecionado
                      if (_selectedMedication != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedMedication!.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Classe: ${_selectedMedication!.category}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              if (_selectedMedication!.tradeName != null)
                                Text(
                                  'Nome comercial: ${_selectedMedication!.tradeName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Faixa de dose: ${_selectedMedication!.minDose}-${_selectedMedication!.maxDose} ${_selectedMedication!.unit}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Indicador de carregamento
                      if (_isLoadingMedications)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Carregando fármacos...',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Campo Peso
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg) *',
                  hintText: 'digite o peso em kg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  final weight = double.tryParse(value.replaceAll(',', '.'));
                  if (weight == null || weight <= 0) {
                    return 'Digite um peso válido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Campo Dose com seletor de unidade (responsivo)
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < 480) {
                  // Em telas estreitas empilhar os campos
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _doseController,
                        decoration: const InputDecoration(
                          labelText: 'Dose *',
                          hintText: 'digite a dose',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medication),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          final dose = double.tryParse(value.replaceAll(',', '.'));
                          if (dose == null || dose <= 0) {
                            return 'Digite uma dose válida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _doseUnit,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Unidade',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'mg/kg', child: Text('mg/kg')),
                          DropdownMenuItem(value: 'mcg/kg', child: Text('mcg/kg')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _doseUnit = value ?? 'mg/kg';
                            _updateLiveCalculation();
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  // Layout em linha para telas maiores
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _doseController,
                          decoration: const InputDecoration(
                            labelText: 'Dose *',
                            hintText: 'digite a dose',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.medication),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            final dose = double.tryParse(value.replaceAll(',', '.'));
                            if (dose == null || dose <= 0) {
                              return 'Digite uma dose válida';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _doseUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Unidade',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'mg/kg', child: Text('mg/kg')),
                            DropdownMenuItem(value: 'mcg/kg', child: Text('mcg/kg')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _doseUnit = value ?? 'mg/kg';
                              _updateLiveCalculation();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),
              
              const SizedBox(height: 16),
              
              // Campo Concentração com seletor de unidade (responsivo)
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < 480) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _concentrationController,
                        decoration: const InputDecoration(
                          labelText: 'Concentração *',
                          hintText: 'digite a concentração',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.science),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          final concentration = double.tryParse(value.replaceAll(',', '.'));
                          if (concentration == null || concentration <= 0) {
                            return 'Digite uma concentração válida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _concentrationUnit,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Unidade',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'mg/ml', child: Text('mg/ml')),
                          DropdownMenuItem(value: 'mcg/ml', child: Text('mcg/ml')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _concentrationUnit = value ?? 'mg/ml';
                            _updateLiveCalculation();
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _concentrationController,
                          decoration: const InputDecoration(
                            labelText: 'Concentração *',
                            hintText: 'digite a concentração',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.science),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            final concentration = double.tryParse(value.replaceAll(',', '.'));
                            if (concentration == null || concentration <= 0) {
                              return 'Digite uma concentração válida';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _concentrationUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Unidade',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'mg/ml', child: Text('mg/ml')),
                            DropdownMenuItem(value: 'mcg/ml', child: Text('mcg/ml')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _concentrationUnit = value ?? 'mg/ml';
                              _updateLiveCalculation();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),
              
              const SizedBox(height: 24),
              
              // Botões de Ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFields,
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculatedVolume != null ? _saveCalculationToHistory : null,
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Resultado do Cálculo
              if (_calculatedVolume != null) ...[
                Card(
                  elevation: 4,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Volume a ser administrado:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_calculatedVolume!.toStringAsFixed(3)} ml',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Validação de dose segura (se fármaco selecionado)
                if (_selectedMedication != null && _weightController.text.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
                      final dose = double.tryParse(_doseController.text.replaceAll(',', '.'));
                      
                      if (weight != null && dose != null) {
                        final doseInMg = _doseUnit == 'mcg/kg' ? dose / 1000 : dose;
                        final totalDose = doseInMg * weight;
                        final safeRange = _selectedMedication!.getSafeDoseRange(weight);
                        final minSafeDose = safeRange['min']!;
                        final maxSafeDose = safeRange['max']!;
                        
                        // Converte para mesma unidade do medicamento
                        final medUnitInMg = _selectedMedication!.unit.toLowerCase().contains('mcg') ? 1000 : 1;
                        final minSafeDoseConverted = minSafeDose / medUnitInMg;
                        final maxSafeDoseConverted = maxSafeDose / medUnitInMg;
                        final totalDoseConverted = totalDose * medUnitInMg;
                        
                        final isSafe = totalDoseConverted >= minSafeDoseConverted && 
                                      totalDoseConverted <= maxSafeDoseConverted;
                        final isBelowMin = totalDoseConverted < minSafeDoseConverted;
                        
                        return Card(
                          elevation: 2,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Referência de Dose',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Dose mínima: ${_selectedMedication!.minDose} ${_selectedMedication!.unit}',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Dose máxima: ${_selectedMedication!.maxDose} ${_selectedMedication!.unit}',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Para ${weight}kg: ${minSafeDoseConverted.toStringAsFixed(2)}-${maxSafeDoseConverted.toStringAsFixed(2)} ${_selectedMedication!.unit}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                // Indicador visual discreto
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSafe 
                                            ? Colors.green.withOpacity(0.2)
                                            : (isBelowMin 
                                                ? Colors.orange.withOpacity(0.2)
                                                : Colors.red.withOpacity(0.2)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSafe ? Icons.check_circle_outline : Icons.info_outline,
                                            size: 14,
                                            color: isSafe 
                                                ? Colors.green.shade700
                                                : (isBelowMin ? Colors.orange.shade700 : Colors.red.shade700),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSafe 
                                                ? 'Dentro da faixa'
                                                : (isBelowMin ? 'Abaixo da faixa' : 'Acima da faixa'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isSafe 
                                                  ? Colors.green.shade700
                                                  : (isBelowMin ? Colors.orange.shade700 : Colors.red.shade700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
              const SizedBox(height: 16),
              // Aviso importante (moved para a parte inferior da página)
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'AVISO IMPORTANTE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esta calculadora é uma ferramenta auxiliar. Sempre consulte bulas, '
                        'protocolos institucionais e utilize seu julgamento clínico. '
                        'O uso responsável e a verificação das doses são essenciais para '
                        'a segurança do paciente.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Histórico de Cálculos
              if (_history.isNotEmpty) ...[
                const Divider(height: 32),
                Text(
                  'Histórico de Cálculos (últimos 10)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      key: item.key,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
                        ),
                        title: Text(
                          'Volume: ${item.volume.toStringAsFixed(3)} ml',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Peso: ${item.weight}kg, Dose: ${item.dose}${item.doseUnit}, Conc: ${item.concentration}${item.concentrationUnit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.history),
                        onTap: () {
                          // Preencher os campos com os dados do histórico
                          _weightController.text = item.weight.toString();
                          _doseController.text = item.dose.toString();
                          _concentrationController.text = item.concentration.toString();
                          setState(() {
                            _doseUnit = item.doseUnit;
                            _concentrationUnit = item.concentrationUnit;
                          });
                          // Recalcular para atualizar a UI
                          _updateLiveCalculation();
                          // Scroll para o topo para ver os campos preenchidos
                          Scrollable.ensureVisible(
                            _formKey.currentContext!,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}
