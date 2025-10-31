import 'package:flutter/material.dart';
import '../models/medicacao.dart';

/// Tabela dinâmica melhorada para medicação com edição inline.
class DynamicTable extends StatelessWidget {
  final String title;
  final List<Medicacao> items;
  final Function(Medicacao) onAdd;
  final void Function(int index) onRemove;
  final void Function(int index, Medicacao updated)? onUpdate;

  const DynamicTable({
    super.key,
    required this.title,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    this.onUpdate,
  });

  void _showAddDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final doseController = TextEditingController();
    final viaController = TextEditingController();
    final tecnicaController = TextEditingController(); // Controller for the new field
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Adicionar $title'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // New "Técnica" field
                TextField(
                  controller: tecnicaController,
                  decoration: const InputDecoration(
                    labelText: 'Técnica',
                    hintText: 'Ex: Bloqueio epidural, etc.',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Fármaco *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: doseController,
                  decoration: const InputDecoration(labelText: 'Dose'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: viaController,
                  decoration: const InputDecoration(labelText: 'Via'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
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
                if (nomeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nome do fármaco é obrigatório')),
                  );
                  return;
                }

                final now = DateTime.now();
                final hora = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final med = Medicacao(
                  nome: nomeController.text.trim(),
                  dose: doseController.text.trim(),
                  via: viaController.text.trim(),
                  hora: hora,
                  tecnica: tecnicaController.text.trim(), // Pass the new field
                );

                onAdd(med);
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Nenhuma entrada. Clique em "Adicionar" para começar.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final m = items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(m.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the new "Técnica" field if it exists
                          if (m.tecnica != null && m.tecnica!.isNotEmpty)
                            Text('Técnica: ${m.tecnica}'),
                          if (m.dose != null && m.dose!.isNotEmpty) Text('Dose: ${m.dose}'),
                          if (m.via != null && m.via!.isNotEmpty) Text('Via: ${m.via}'),
                          if (m.hora != null)
                            Text(
                                'Hora: ${m.hora!.hour.toString().padLeft(2, '0')}:${m.hora!.minute.toString().padLeft(2, '0')}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => onRemove(i),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
