import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'apple_fast_controller.dart';
import '../apple_full/widgets/parameter_input.dart';

class AppleFastPage extends StatefulWidget {
  const AppleFastPage({super.key});

  @override
  State<AppleFastPage> createState() => _AppleFastPageState();
}

class _AppleFastPageState extends State<AppleFastPage> {
  late final AppleFastController _controller;
  final _cGlucose = TextEditingController();
  final _cAlbumin = TextEditingController();
  final _cPlatelets = TextEditingController();
  final _cLact = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AppleFastController();
  }

  @override
  void dispose() {
    _cGlucose.dispose();
    _cAlbumin.dispose();
    _cPlatelets.dispose();
    _cLact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(title: const Text('APPLE Fast')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ParameterInput(label: 'Glicose', suffix: 'mg/dL', controller: _cGlucose, onChanged: (v) => _controller.glucose = v),
              const SizedBox(height: 8),
              ParameterInput(label: 'Albumina', suffix: 'g/dL', controller: _cAlbumin, onChanged: (v) => _controller.albumin = v),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Escore de mentação', border: OutlineInputBorder(), isDense: true),
                initialValue: _controller.mentationScore,
                items: List.generate(5, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                onChanged: (v) => setState(() => _controller.mentationScore = v ?? 0),
              ),
              const SizedBox(height: 8),
              ParameterInput(label: 'Plaquetas', controller: _cPlatelets, onChanged: (v) => _controller.plateletCount = v, hintText: 'x10³/μL'),
              const SizedBox(height: 8),
              ParameterInput(label: 'Lactato', suffix: 'mmol/L', controller: _cLact, onChanged: (v) => _controller.lactate = v),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Resultado', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Score: ${_controller.totalScore}'),
                      const SizedBox(height: 6),
                      Text('Probabilidade: ${(_controller.mortalityProbability*100).toStringAsFixed(1)} %', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _controller.saveToHistory();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo no histórico')));
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
