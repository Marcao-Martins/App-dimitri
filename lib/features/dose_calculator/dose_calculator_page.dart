import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'oxygen_autonomy_calculator_page.dart';
import '../unit_converter/unit_converter_page.dart';

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
  
  String _doseUnit = 'mcg/kg';
  String _concentrationUnit = 'mcg/ml';
  double? _calculatedVolume;
  final List<CalculationHistory> _history = [];
  
  @override
  void initState() {
    super.initState();
    // Calcular em tempo real
    _weightController.addListener(_updateLiveCalculation);
    _doseController.addListener(_updateLiveCalculation);
    _concentrationController.addListener(_updateLiveCalculation);
  }
  
  @override
  void dispose() {
    _weightController.dispose();
    _doseController.dispose();
    _concentrationController.dispose();
    super.dispose();
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
    return Scaffold(
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aviso importante
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
              
              // Campo Dose com seletor de unidade
              Row(
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
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _doseUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'mcg/kg', child: Text('mcg/kg')),
                        DropdownMenuItem(value: 'mg/kg', child: Text('mg/kg')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _doseUnit = value ?? 'mcg/kg';
                          _updateLiveCalculation();
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Campo Concentração com seletor de unidade
              Row(
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
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _concentrationUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'mcg/ml', child: Text('mcg/ml')),
                        DropdownMenuItem(value: 'mg/ml', child: Text('mg/ml')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _concentrationUnit = value ?? 'mcg/ml';
                          _updateLiveCalculation();
                        });
                      },
                    ),
                  ),
                ],
              ),
              
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
              if (_calculatedVolume != null)
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
    );
  }
}
