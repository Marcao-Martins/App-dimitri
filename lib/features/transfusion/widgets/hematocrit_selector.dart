import 'package:flutter/material.dart';

/// Widget para seleção de hematócrito com range customizado
class HematocritSelector extends StatelessWidget {
  final String label;
  final int? value;
  final int minValue;
  final int maxValue;
  final IconData icon;
  final Function(int?) onChanged;
  final String? helperText;
  final String? Function(int?)? validator;

  const HematocritSelector({
    super.key,
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.icon,
    required this.onChanged,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Gera lista de valores do range
    final items = List.generate(
      maxValue - minValue + 1,
      (index) => minValue + index,
    );

    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: '%',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        helperText: helperText,
      ),
      items: items.map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value%'),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }
}
