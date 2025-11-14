import 'package:flutter/material.dart';

typedef OnDoubleChanged = void Function(double? value);

class ParameterInput extends StatelessWidget {
  final String label;
  final String? suffix;
  final String? hintText;
  final OnDoubleChanged onChanged;
  final TextEditingController controller;

  const ParameterInput({
    super.key,
    required this.label,
    required this.onChanged,
    required this.controller,
    this.suffix,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (v) {
        final cleaned = v.replaceAll(',', '.').trim();
        final parsed = double.tryParse(cleaned);
        onChanged(parsed);
      },
    );
  }
}
