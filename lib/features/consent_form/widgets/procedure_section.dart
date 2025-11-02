// lib/features/consent_form/widgets/procedure_section.dart
// Seção de dados do Procedimento

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProcedureSection extends StatelessWidget {
  final TextEditingController procedureController;
  final TextEditingController additionalInfoController;
  final TextEditingController cityController;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const ProcedureSection({
    super.key,
    required this.procedureController,
    required this.additionalInfoController,
    required this.cityController,
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dados do Procedimento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: procedureController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Anestesia/Procedimento *',
                hintText: 'Ex: Anestesia geral para castração',
                prefixIcon: Icon(Icons.medication),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: additionalInfoController,
              decoration: const InputDecoration(
                labelText: 'Outras Informações (opcional)',
                hintText: 'Informações adicionais relevantes',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Cidade *',
                hintText: 'Ex: São Paulo',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  dateFormat.format(selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
