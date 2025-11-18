import 'package:flutter/material.dart';

/// Widget para seção de desidratação com campos condicionais
class DehydrationSection extends StatelessWidget {
  final bool hasDehydration;
  final int? rehydrationTime;
  final TextEditingController dehydrationController;
  final Function(int?) onRehydrationTimeChanged;

  const DehydrationSection({
    super.key,
    required this.hasDehydration,
    required this.rehydrationTime,
    required this.dehydrationController,
    required this.onRehydrationTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasDehydration) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Tempo de reidratação
        DropdownButtonFormField<int>(
          initialValue: rehydrationTime,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Tempo para reidratação',
            prefixIcon: const Icon(Icons.schedule),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: const [
            DropdownMenuItem(value: 12, child: Text('12 horas')),
            DropdownMenuItem(value: 24, child: Text('24 horas')),
          ],
          onChanged: onRehydrationTimeChanged,
          validator: (value) {
            if (hasDehydration && value == null) {
              return 'Selecione o tempo de reidratação';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Percentual de desidratação
        TextFormField(
          controller: dehydrationController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Desidratação (%)',
            hintText: 'Ex: 5.0',
            prefixIcon: const Icon(Icons.water_drop),
            suffixText: '%',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            helperText: 'Valor entre 0 e 20%',
          ),
          validator: (value) {
            if (hasDehydration) {
              if (value == null || value.isEmpty) {
                return 'Informe o percentual de desidratação';
              }
              final percent = double.tryParse(value.replaceAll(',', '.'));
              if (percent == null) {
                return 'Valor inválido';
              }
              if (percent < 0 || percent > 20) {
                return 'Valor deve estar entre 0 e 20%';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
