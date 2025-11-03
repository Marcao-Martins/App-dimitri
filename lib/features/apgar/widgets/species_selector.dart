import 'package:flutter/material.dart';

/// Widget para seleção de espécie
class SpeciesSelector extends StatelessWidget {
  final String? selectedSpecies;
  final ValueChanged<String?> onChanged;

  const SpeciesSelector({
    super.key,
    required this.selectedSpecies,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pets,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Espécie do Neonato',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedSpecies,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              hintText: 'Selecione a espécie',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            dropdownColor: Theme.of(context).cardColor,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: 'Cão',
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Color(0xFF1565C0)),
                    SizedBox(width: 12),
                    Text(
                      'Cão',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Gato',
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Color(0xFF1565C0)),
                    SizedBox(width: 12),
                    Text(
                      'Gato',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione a espécie';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
