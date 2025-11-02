// lib/features/consent_form/widgets/doctor_section.dart
// Seção de dados do Médico Veterinário

import 'package:flutter/material.dart';

class DoctorSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController crmvController;
  final TextEditingController clinicController;

  const DoctorSection({
    super.key,
    required this.nameController,
    required this.crmvController,
    required this.clinicController,
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
                  Icons.medical_services,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dados do Médico Veterinário',
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
                labelText: 'Nome do Veterinário *',
                hintText: 'Ex: Dr. João Silva',
                prefixIcon: Icon(Icons.person),
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
            TextFormField(
              controller: crmvController,
              decoration: const InputDecoration(
                labelText: 'CRMV *',
                hintText: 'Ex: SP 12345',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: clinicController,
              decoration: const InputDecoration(
                labelText: 'Clínica/Hospital *',
                hintText: 'Ex: Clínica Veterinária Pet Saúde',
                prefixIcon: Icon(Icons.local_hospital),
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
          ],
        ),
      ),
    );
  }
}
