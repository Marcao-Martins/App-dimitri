// lib/features/consent_form/widgets/animal_section.dart
// Seção de dados do Animal

import 'package:flutter/material.dart';

class AnimalSection extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedSpecies;
  final ValueChanged<String?> onSpeciesChanged;
  final TextEditingController breedController;
  final String selectedSex;
  final ValueChanged<String?> onSexChanged;

  const AnimalSection({
    super.key,
    required this.nameController,
    required this.selectedSpecies,
    required this.onSpeciesChanged,
    required this.breedController,
    required this.selectedSex,
    required this.onSexChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icons.pets,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dados do Paciente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Paciente *',
                hintText: 'Ex: Rex',
                prefixIcon: Icon(Icons.pets),
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
            DropdownButtonFormField<String>(
              initialValue: selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Espécie *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Cão', child: Text('Cão')),
                DropdownMenuItem(value: 'Gato', child: Text('Gato')),
              ],
              onChanged: onSpeciesChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: breedController,
              decoration: const InputDecoration(
                labelText: 'Raça *',
                hintText: 'Ex: Golden Retriever',
                prefixIcon: Icon(Icons.info_outline),
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
            DropdownButtonFormField<String>(
              initialValue: selectedSex,
              decoration: const InputDecoration(
                labelText: 'Sexo *',
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
              ],
              onChanged: onSexChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
