import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ficha_provider.dart';

class AirwayManagement extends StatelessWidget {
  const AirwayManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FichaProvider>(context);
    final current = provider.current;

    // helper to build tube size options (2.0 to 10.0 step 0.5)
    List<String> tubeSizes() {
      final List<String> list = ['Selecione...'];
      for (double s = 2.0; s <= 10.0; s += 0.5) {
        final str = s.toStringAsFixed((s % 1 == 0) ? 0 : 1);
        list.add(str);
      }
      list.add('Outro');
      return list;
    }

    final sizes = tubeSizes();

    Widget buildDropdown({required String label, required String? value, required List<String> options, required ValueChanged<String?> onChanged}) {
      return DropdownButtonFormField<String>(
        initialValue: value ?? 'Selecione...',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        isExpanded: true,
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.airline_stops, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Manejo de Vias Aéreas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Linha 1
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;
              if (isNarrow) {
                return Column(
                  children: [
                    buildDropdown(
                      label: 'Intubação orotraqueal',
                      value: current?.airwayIntubation,
                      options: const ['Selecione...', 'Sim', 'Não'],
                      onChanged: (v) => provider.setAirwayIntubation(v),
                    ),
                    const SizedBox(height: 12),
                    buildDropdown(
                      label: 'Sonda endotraqueal (tamanho)',
                      value: current?.airwayTubeSize,
                      options: sizes,
                      onChanged: (v) => provider.setAirwayTubeSize(v),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: buildDropdown(
                      label: 'Intubação orotraqueal',
                      value: current?.airwayIntubation,
                      options: const ['Selecione...', 'Sim', 'Não'],
                      onChanged: (v) => provider.setAirwayIntubation(v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildDropdown(
                      label: 'Sonda endotraqueal (tamanho)',
                      value: current?.airwayTubeSize,
                      options: sizes,
                      onChanged: (v) => provider.setAirwayTubeSize(v),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 12),

            // Linha 2
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;
              if (isNarrow) {
                return Column(
                  children: [
                    buildDropdown(
                      label: 'Pré-oxigenação',
                      value: current?.airwayPreOxygenation,
                      options: const ['Selecione...', 'Sim', 'Não'],
                      onChanged: (v) => provider.setAirwayPreOxygenation(v),
                    ),
                    const SizedBox(height: 12),
                    buildDropdown(
                      label: 'Anestesia periglótica',
                      value: current?.airwayPeriglotticAnesthesia,
                      options: const ['Selecione...', 'Sim', 'Não'],
                      onChanged: (v) => provider.setAirwayPeriglotticAnesthesia(v),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: buildDropdown(
                      label: 'Pré-oxigenação',
                      value: current?.airwayPreOxygenation,
                      options: const ['Selecione...', 'Sim', 'Não'],
                      onChanged: (v) => provider.setAirwayPreOxygenation(v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildDropdown(
                      label: 'Anestesia periglótica',
                      value: current?.airwayPeriglotticAnesthesia,
                      options: const ['Selecione...', 'Sim', 'Não'],
                      onChanged: (v) => provider.setAirwayPeriglotticAnesthesia(v),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 12),

            // Linha 3: Laryngeal mask
            buildDropdown(
              label: 'Máscara laríngea',
              value: current?.airwayLaryngealMask,
              options: const ['Selecione...', 'Sim', 'Não'],
              onChanged: (v) => provider.setAirwayLaryngealMask(v),
            ),

            const SizedBox(height: 12),

            // Observações
            TextFormField(
              initialValue: current?.airwayObservations ?? '',
              onChanged: (v) => provider.setAirwayObservations(v),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Digite observações adicionais...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
