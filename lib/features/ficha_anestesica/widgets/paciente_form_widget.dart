import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/paciente.dart';

class PacienteFormWidget extends StatefulWidget {
  final Paciente? paciente;
  final Function(Paciente) onSave;

  const PacienteFormWidget({
    Key? key,
    this.paciente,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PacienteFormWidget> createState() => _PacienteFormWidgetState();
}

class _PacienteFormWidgetState extends State<PacienteFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _pesoController;
  late TextEditingController _idadeController;
  late TextEditingController _procedimentoController;
  late TextEditingController _doencasController;
  late TextEditingController _observacoesController;

  String? _especie;
  String? _sexo;
  String? _asa;
  DateTime? _data;

  final List<String> _especies = ['Cão', 'Gato', 'Equino', 'Bovino', 'Ovino', 'Outro'];
  final List<String> _sexos = ['Macho', 'Fêmea'];
  final List<String> _asaOptions = ['ASA I', 'ASA II', 'ASA III', 'ASA IV', 'ASA V'];

  @override
  void initState() {
    super.initState();
    final p = widget.paciente;
    _nomeController = TextEditingController(text: p?.nome ?? '');
    _pesoController = TextEditingController(text: p?.peso?.toString() ?? '');
    _idadeController = TextEditingController(text: p?.idade ?? '');
    _procedimentoController = TextEditingController(text: p?.procedimento ?? '');
    _doencasController = TextEditingController(text: p?.doencas ?? '');
    _observacoesController = TextEditingController(text: p?.observacoes ?? '');
    
    _especie = p?.especie;
    _sexo = p?.sexo;
    _asa = p?.asa;
    _data = p?.data ?? DateTime.now();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pesoController.dispose();
    _idadeController.dispose();
    _procedimentoController.dispose();
    _doencasController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final paciente = Paciente(
      nome: _nomeController.text.trim(),
      data: _data,
      especie: _especie,
      sexo: _sexo,
      peso: double.tryParse(_pesoController.text.trim()),
      idade: _idadeController.text.trim(),
      asa: _asa,
      procedimento: _procedimentoController.text.trim(),
      doencas: _doencasController.text.trim(),
      observacoes: _observacoesController.text.trim(),
    );

    widget.onSave(paciente);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identificação do Paciente', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              
              // Nome (obrigatório)
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Paciente *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Data
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Data'),
                      subtitle: Text(_data != null ? '${_data!.day}/${_data!.month}/${_data!.year}' : 'Selecionar'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _data ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _data = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Espécie e Sexo
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _especie,
                      decoration: const InputDecoration(
                        labelText: 'Espécie *',
                        border: OutlineInputBorder(),
                      ),
                      items: _especies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) => setState(() => _especie = value),
                      validator: (value) => value == null ? 'Selecione a espécie' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sexo,
                      decoration: const InputDecoration(
                        labelText: 'Sexo *',
                        border: OutlineInputBorder(),
                      ),
                      items: _sexos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) => setState(() => _sexo = value),
                      validator: (value) => value == null ? 'Selecione o sexo' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Peso e Idade
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pesoController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Peso é obrigatório';
                        }
                        final peso = double.tryParse(value);
                        if (peso == null || peso <= 0) {
                          return 'Peso inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _idadeController,
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: 5 anos',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ASA
              DropdownButtonFormField<String>(
                value: _asa,
                decoration: const InputDecoration(
                  labelText: 'Classificação ASA *',
                  border: OutlineInputBorder(),
                ),
                items: _asaOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => _asa = value),
                validator: (value) => value == null ? 'Selecione a classificação ASA' : null,
              ),
              const SizedBox(height: 12),

              // Procedimento
              TextFormField(
                controller: _procedimentoController,
                decoration: const InputDecoration(
                  labelText: 'Procedimento',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Doenças
              TextFormField(
                controller: _doencasController,
                decoration: const InputDecoration(
                  labelText: 'Doenças Preexistentes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Paciente'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
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
