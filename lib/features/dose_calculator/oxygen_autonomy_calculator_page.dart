import 'package:flutter/material.dart';

class OxygenAutonomyCalculatorPage extends StatefulWidget {
  const OxygenAutonomyCalculatorPage({super.key});

  @override
  State<OxygenAutonomyCalculatorPage> createState() =>
      _OxygenAutonomyCalculatorPageState();
}

class _Cylinder {
  final String type;
  final double conversionFactor;

  _Cylinder(this.type, this.conversionFactor);
}

class _OxygenAutonomyCalculatorPageState
    extends State<OxygenAutonomyCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _pressureController = TextEditingController();
  final _flowController = TextEditingController();

  final List<_Cylinder> _cylinders = [
    _Cylinder('E', 0.28),
    _Cylinder('D', 0.16),
    _Cylinder('C', 0.08),
    _Cylinder('M', 1.56),
    _Cylinder('G', 2.41),
  ];

  _Cylinder? _selectedCylinder;
  String? _result;

  @override
  void initState() {
    super.initState();
    _selectedCylinder = _cylinders.first;
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final pressure = double.tryParse(_pressureController.text);
      final flow = double.tryParse(_flowController.text);

      if (pressure != null && flow != null && flow > 0 && _selectedCylinder != null) {
        final timeInMinutes =
            (pressure * _selectedCylinder!.conversionFactor) / flow;

        if (timeInMinutes.isFinite && !timeInMinutes.isNegative) {
          final hours = timeInMinutes ~/ 60;
          final minutes = (timeInMinutes % 60).round();
          setState(() {
            _result = '${hours} horas e ${minutes} minutos';
          });
        } else {
           setState(() {
            _result = 'Cálculo inválido. Verifique os valores.';
          });
        }
      }
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    _pressureController.clear();
    _flowController.clear();
    setState(() {
      _selectedCylinder = _cylinders.first;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonomia do Cilindro de O₂'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Limpar campos',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown para Tipo de Cilindro
              DropdownButtonFormField<_Cylinder>(
                value: _selectedCylinder,
                items: _cylinders.map((cylinder) {
                  return DropdownMenuItem(
                    value: cylinder,
                    child: Text('Cilindro Tipo ${cylinder.type}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCylinder = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Tipo de Cilindro',
                  prefixIcon: Icon(Icons.propane_tank_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Campo para Pressão
              TextFormField(
                controller: _pressureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pressão Atual (psi)',
                  prefixIcon: Icon(Icons.compress),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valor numérico inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo para Fluxo
              TextFormField(
                controller: _flowController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fluxo de Oxigênio (L/min)',
                  prefixIcon: Icon(Icons.air),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  final flow = double.tryParse(value);
                   if (flow == null) {
                    return 'Valor numérico inválido';
                  }
                  if (flow <= 0) {
                    return 'O fluxo deve ser maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão Calcular
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Resultado
              if (_result != null)
                Card(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Tempo Restante Estimado:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _result!,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
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
