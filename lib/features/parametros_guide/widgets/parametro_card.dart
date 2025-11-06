import 'package:flutter/material.dart';
import '../models/parametro.dart';
import '../parametros_controller.dart';

class ParametroCard extends StatelessWidget {
  final Parametro parametro;
  final Species selectedSpecies;

  const ParametroCard({
    Key? key,
    required this.parametro,
    required this.selectedSpecies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String value = '';
    switch (selectedSpecies) {
      case Species.cao:
        value = parametro.cao;
        break;
      case Species.gato:
        value = parametro.gato;
        break;
      case Species.cavalo:
        value = parametro.cavalo;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parametro.nome,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (value.isNotEmpty)
              Text(
                'Valor: $value',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (parametro.comentarios.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Observações: ${parametro.comentarios}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (parametro.referencias.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Referências: ${parametro.referencias}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
