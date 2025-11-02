import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'oxygen_autonomy_calculator_page.dart';
import '../unit_converter/unit_converter_page.dart';

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
  
  @override
  void initState() {
    super.initState();
    // Calcular em tempo real
    _weightController.addListener(_calculateVolume);
    _doseController.addListener(_calculateVolume);
    _concentrationController.addListener(_calculateVolume);
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
  
  /// Calcula o volume necessário
  void _calculateVolume() {
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
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange.shade800),
                          const SizedBox(width: 8),
                          Text(
                            'AVISO IMPORTANTE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
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
                          color: Colors.grey.shade800,
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
                          _calculateVolume();
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
                          _calculateVolume();
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Botão Limpar
              OutlinedButton.icon(
                onPressed: _clearFields,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resultado
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calculate,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Volume total (ml)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _calculatedVolume != null
                              ? 'Volume final: ${_calculatedVolume!.toStringAsFixed(2)} ml'
                              : 'Preencha todos os campos para calcular',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _calculatedVolume != null
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (_calculatedVolume != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Fórmula: (Peso × Dose) / Concentração',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nota de rodapé
              Text(
                '* Campos obrigatórios',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
