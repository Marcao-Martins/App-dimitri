import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'apple_full_controller.dart';
import 'widgets/parameter_input.dart';
import 'widgets/mortality_calculator.dart';

class AppleFullPage extends StatefulWidget {
  const AppleFullPage({super.key});

  @override
  State<AppleFullPage> createState() => _AppleFullPageState();
}

class _AppleFullPageState extends State<AppleFullPage> {
  late final AppleFullController _controller;

  final _cCreat = TextEditingController();
  final _cWbc = TextEditingController();
  final _cAlbumin = TextEditingController();
  final _cSpO2 = TextEditingController();
  final _cBili = TextEditingController();
  final _cResp = TextEditingController();
  final _cAge = TextEditingController();
  final _cLact = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AppleFullController();
  }

  @override
  void dispose() {
    _cCreat.dispose();
    _cWbc.dispose();
    _cAlbumin.dispose();
    _cSpO2.dispose();
    _cBili.dispose();
    _cResp.dispose();
    _cAge.dispose();
    _cLact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(title: const Text('APPLE Full')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ParameterInput(label: 'Creatinina', suffix: 'mg/dL', controller: _cCreat, onChanged: (v) => _controller.creatinine = v),
              const SizedBox(height: 8),
              ParameterInput(label: 'WBC (x10³/μL)', controller: _cWbc, onChanged: (v) => _controller.wbcCount = v),
              const SizedBox(height: 8),
              ParameterInput(label: 'Albumina', suffix: 'g/dL', controller: _cAlbumin, onChanged: (v) => _controller.albumin = v),
              const SizedBox(height: 8),
              ParameterInput(label: 'SpO2', suffix: '%', controller: _cSpO2, onChanged: (v) => _controller.spo2 = v),
              const SizedBox(height: 8),
              ParameterInput(label: 'Bilirrubina total', suffix: 'mg/dL', controller: _cBili, onChanged: (v) => _controller.totalBilirubin = v),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Escore de mentação', border: OutlineInputBorder(), isDense: true),
                initialValue: _controller.mentationScore,
                items: List.generate(5, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                onChanged: (v) => setState(() => _controller.mentationScore = v ?? 0),
              ),
              const SizedBox(height: 8),
              ParameterInput(label: 'Frequência respiratória', suffix: 'mpm', controller: _cResp, onChanged: (v) => _controller.respiratoryRate = v?.round()),
              const SizedBox(height: 8),
              ParameterInput(label: 'Idade', suffix: 'anos', controller: _cAge, onChanged: (v) => _controller.ageYears = v?.round()),
              const SizedBox(height: 8),
              ParameterInput(label: 'Lactato', suffix: 'mmol/L', controller: _cLact, onChanged: (v) => _controller.lactate = v),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Fluido em cavidade', border: OutlineInputBorder(), isDense: true),
                value: _controller.fluidScore,
                items: [0,1,2].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                onChanged: (v) => setState(() => _controller.fluidScore = v ?? 0),
              ),
              const SizedBox(height: 16),
              const MortalityCalculator(),
            ],
          ),
        ),
      ),
    );
  }
}
