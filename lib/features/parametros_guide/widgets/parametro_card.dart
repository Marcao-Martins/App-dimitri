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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do parâmetro
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.monitor_heart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    parametro.nome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Seções por espécie (Cão, Gato, Cavalo)
            _speciesTile(
              context,
              label: 'Cão',
              value: parametro.cao,
              icon: Icons.pets,
              color: theme.colorScheme.primary,
              highlighted: selectedSpecies == Species.cao,
            ),
            const SizedBox(height: 8),
            _speciesTile(
              context,
              label: 'Gato',
              value: parametro.gato,
              icon: Icons.pets,
              color: Colors.cyan.shade700, // Cor azul-ciano para diferenciar do laranja
              highlighted: selectedSpecies == Species.gato,
            ),
            const SizedBox(height: 8),
            _speciesTile(
              context,
              label: 'Cavalo',
              value: parametro.cavalo,
              icon: Icons.pets,
              color: theme.colorScheme.tertiary,
              highlighted: selectedSpecies == Species.cavalo,
            ),

            // Comentários
            if (parametro.comentarios.trim().isNotEmpty && parametro.comentarios.trim() != '-') ...[
              const SizedBox(height: 12),
              _sectionHeader(
                context,
                icon: Icons.info_outline,
                title: 'Comentários',
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 6),
              _sectionBody(
                context,
                parametro.comentarios,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ],

            // Referências
            if (parametro.referencias.trim().isNotEmpty && parametro.referencias.trim() != '-') ...[
              const SizedBox(height: 12),
              _sectionHeader(
                context,
                icon: Icons.book_outlined,
                title: 'Referências',
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 6),
              _sectionBody(
                context,
                parametro.referencias,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                italic: true,
                maxLines: 6,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _speciesTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool highlighted = false,
  }) {
    final theme = Theme.of(context);
    final hasValue = value.trim().isNotEmpty && value.trim() != '-';
    final display = hasValue ? value.trim() : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? color : theme.dividerColor.withValues(alpha: 0.5),
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              softWrap: true,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasValue
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _sectionBody(
    BuildContext context,
    String text, {
    Color? color,
    bool italic = false,
    int? maxLines,
  }) {
    final theme = Theme.of(context);
    return Text(
      text,
      softWrap: true,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
      style: theme.textTheme.bodySmall?.copyWith(
        color: color,
        fontStyle: italic ? FontStyle.italic : null,
        height: 1.25,
      ),
    );
  }
}
