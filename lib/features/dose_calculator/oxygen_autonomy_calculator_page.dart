import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/tool_box.dart';
import '../../core/constants/tool_colors.dart';

class FlowResult {
  final double flowRate;
  final String duration;

  FlowResult(this.flowRate, this.duration);
}

class OxygenAutonomyCalculatorPage extends StatefulWidget {
  const OxygenAutonomyCalculatorPage({super.key});

  @override
  State<OxygenAutonomyCalculatorPage> createState() =>
      _OxygenAutonomyCalculatorPageState();
}

class _OxygenAutonomyCalculatorPageState
    extends State<OxygenAutonomyCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cylinderSizeController = TextEditingController();
  final _pressureController = TextEditingController();

  String _pressureUnit = 'bar';
  double? _totalContent;
  List<FlowResult> _results = [];

  final List<double> _flowRates = [0.5, 1, 2, 3, 4, 5, 10];

  // Conversão de diferentes unidades para bar
  double _convertToBar(int pressure, String unit) {
    switch (unit) {
      case 'bar':
        return pressure.toDouble();
      case 'psi':
        return pressure * 0.0689476; // 1 psi = 0.0689476 bar
      case 'kgf/cm²':
        return pressure * 0.980665; // 1 kgf/cm² = 0.980665 bar
      case 'kPa':
        return pressure * 0.01; // 1 kPa = 0.01 bar
      default:
        return pressure.toDouble();
    }
  }

  String _formatDuration(double minutes) {
    if (minutes.isInfinite || minutes.isNaN) return '-';
    
    final totalMinutes = minutes.round();
    final days = totalMinutes ~/ 1440; // 1440 min = 1 dia
    final hours = (totalMinutes % 1440) ~/ 60;
    final mins = totalMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days d');
    if (hours > 0) parts.add('$hours h');
    if (mins > 0 || parts.isEmpty) parts.add('$mins min');

    return parts.join(' ');
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final cylinderSize = int.tryParse(_cylinderSizeController.text);
      final pressure = int.tryParse(_pressureController.text);

      if (cylinderSize != null && pressure != null) {
        // Converter pressão para bar
        final pressureInBar = _convertToBar(pressure, _pressureUnit);
        
        // Fórmula: Conteúdo total = Tamanho × Pressão (em bar)
        final content = cylinderSize * pressureInBar;

        setState(() {
          _totalContent = content;
          _results = _flowRates.map((flowRate) {
            final durationMinutes = content / flowRate;
            return FlowResult(flowRate, _formatDuration(durationMinutes));
          }).toList();
        });
      }
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    _cylinderSizeController.clear();
    _pressureController.clear();
    setState(() {
      _pressureUnit = 'bar';
      _totalContent = null;
      _results = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonomia do Cilindro de O₂'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Cabeçalho da ferramenta
              ToolBox(
                title: 'Autonomia de O₂',
                subtitle: 'Estimativa de duração do cilindro por vazão',
                icon: Icons.propane_tank_outlined,
                color: ToolColors.autonomyO2,
              ),
              const SizedBox(height: 12),
              // Informações gerais
                Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INSTRUÇÕES:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Volume interno em litros. Digite apenas números inteiros. Não use ponto nem vírgula.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Leitura do manômetro. Digite apenas números inteiros. Não use ponto nem vírgula.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• A conta converte automaticamente para bar.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo tamanho do cilindro
              TextFormField(
                controller: _cylinderSizeController,
                decoration: const InputDecoration(
                  labelText: 'Tamanho do cilindro (L)',
                  helperText: 'Volume interno em litros (apenas números inteiros)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o tamanho do cilindro';
                  }
                  final size = int.tryParse(value);
                  if (size == null || size <= 0) {
                    return 'Digite um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo pressão
              TextFormField(
                controller: _pressureController,
                decoration: const InputDecoration(
                  labelText: 'Pressão no cilindro',
                  helperText: 'Leitura do manômetro (apenas números inteiros)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a pressão';
                  }
                  final pressure = int.tryParse(value);
                  if (pressure == null || pressure <= 0) {
                    return 'Digite um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Dropdown unidade de pressão
              DropdownButtonFormField<String>(
                initialValue: _pressureUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidade da pressão',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'bar', child: Text('bar')),
                  DropdownMenuItem(value: 'psi', child: Text('psi')),
                  DropdownMenuItem(value: 'kgf/cm²', child: Text('kgf/cm²')),
                  DropdownMenuItem(value: 'kPa', child: Text('kPa')),
                ],
                onChanged: (value) {
                  setState(() {
                    _pressureUnit = value ?? 'bar';
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Calcular'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Limpar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Resultado
              if (_totalContent != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultado',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Conteúdo estimado: ${_totalContent!.toStringAsFixed(0)} L',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Tabela de vazões
                        Text(
                          'Autonomia estimada por vazão:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Table(
                          border: TableBorder.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                          },
                          children: [
                            // Header
                            TableRow(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Vazão (L/min)',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Duração',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            // Data rows
                            ..._results.map((result) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    result.flowRate.toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    result.duration,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
