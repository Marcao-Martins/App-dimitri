import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/parametro_monitorizacao.dart';

class MonitoringTable extends StatelessWidget {
  final List<ParametroMonitorizacao> items;
  final Function(ParametroMonitorizacao) onAddTime;
  final void Function(int index) onRemoveTime;
  final void Function(int index, ParametroMonitorizacao updated)? onUpdate;

  const MonitoringTable({
    super.key,
    required this.items,
    required this.onAddTime,
    required this.onRemoveTime,
    this.onUpdate,
  });

  void _showAddEditDialog(BuildContext context, {int? editIndex, ParametroMonitorizacao? param}) {
    final fcController = TextEditingController(text: param?.fc?.toString() ?? '');
    final frController = TextEditingController(text: param?.fr?.toString() ?? '');
    final spo2Controller = TextEditingController(text: param?.spo2?.toString() ?? '');
    final etco2Controller = TextEditingController(text: param?.etco2?.toString() ?? '');
    final pasController = TextEditingController(text: param?.pas?.toString() ?? '');
    final padController = TextEditingController(text: param?.pad?.toString() ?? '');
    final pamController = TextEditingController(text: param?.pam?.toString() ?? '');
    final tempController = TextEditingController(text: param?.temp?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex == null ? 'Adicionar Parâmetros' : 'Editar Parâmetros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fcController,
                decoration: const InputDecoration(labelText: 'FC (bpm)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: frController,
                decoration: const InputDecoration(labelText: 'FR (mpm)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: spo2Controller,
                decoration: const InputDecoration(labelText: 'SpO2 (%)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: etco2Controller,
                decoration: const InputDecoration(labelText: 'ETCO2 (mmHg)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: pasController,
                decoration: const InputDecoration(labelText: 'PAS (mmHg)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: padController,
                decoration: const InputDecoration(labelText: 'PAD (mmHg)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: pamController,
                decoration: const InputDecoration(labelText: 'PAM (mmHg)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: tempController,
                decoration: const InputDecoration(labelText: 'Temperatura (°C)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newParam = ParametroMonitorizacao(
                momento: param?.momento ?? DateTime.now(),
                fc: int.tryParse(fcController.text),
                fr: int.tryParse(frController.text),
                spo2: int.tryParse(spo2Controller.text),
                etco2: int.tryParse(etco2Controller.text),
                pas: int.tryParse(pasController.text),
                pad: int.tryParse(padController.text),
                pam: int.tryParse(pamController.text),
                temp: double.tryParse(tempController.text),
              );

              if (editIndex == null) {
                onAddTime(newParam);
              } else if (onUpdate != null) {
                onUpdate!(editIndex, newParam);
              }

              Navigator.pop(context);
            },
            child: Text(editIndex == null ? 'Adicionar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monitorização de Parâmetros', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                onPressed: () => _showAddEditDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Adicionar tempo',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Nenhum parâmetro registrado. Clique em + para adicionar.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Tempo')),
                  DataColumn(label: Text('FC')),
                  DataColumn(label: Text('FR')),
                  DataColumn(label: Text('SpO2')),
                  DataColumn(label: Text('ETCO2')),
                  DataColumn(label: Text('PAS')),
                  DataColumn(label: Text('PAD')),
                  DataColumn(label: Text('PAM')),
                  DataColumn(label: Text('Temp')),
                  DataColumn(label: Text('Ações')),
                ],
                rows: items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return DataRow(cells: [
                    DataCell(Text('${p.momento.hour.toString().padLeft(2, '0')}:${p.momento.minute.toString().padLeft(2, '0')}')),
                    DataCell(Text(p.fc?.toString() ?? '-')),
                    DataCell(Text(p.fr?.toString() ?? '-')),
                    DataCell(Text(p.spo2?.toString() ?? '-')),
                    DataCell(Text(p.etco2?.toString() ?? '-')),
                    DataCell(Text(p.pas?.toString() ?? '-')),
                    DataCell(Text(p.pad?.toString() ?? '-')),
                    DataCell(Text(p.pam?.toString() ?? '-')),
                    DataCell(Text(p.temp?.toStringAsFixed(1) ?? '-')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showAddEditDialog(context, editIndex: i, param: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            onPressed: () => onRemoveTime(i),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            )
        ]),
      ),
    );
  }
}
