import 'package:flutter/material.dart';
import '../models/species_config.dart';

/// Widget para seleção de parâmetros do Apgar
class ParameterSelector extends StatelessWidget {
  final String label;
  final String? helperText;
  final List<ApgarOption> options;
  final int? selectedScore;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;

  const ParameterSelector({
    super.key,
    required this.label,
    this.helperText,
    required this.options,
    required this.selectedScore,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Dropdown com opções
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int>(
              value: selectedScore,
              decoration: InputDecoration(
                hintText: 'Selecione uma opção',
                helperText: helperText,
                helperMaxLines: 2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              isExpanded: true,
              items: options.map((option) {
                return DropdownMenuItem<int>(
                  value: option.score,
                  child: Row(
                    children: [
                      // Badge com pontuação
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getScoreColor(option.score),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${option.score}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Label e descrição
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              option.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              option.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    switch (score) {
      case 2:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 0:
      default:
        return Colors.red;
    }
  }
}
