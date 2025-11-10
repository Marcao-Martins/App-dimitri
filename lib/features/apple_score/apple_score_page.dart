import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'apple_score_controller.dart';
import 'apple_score_model.dart';

class AppleScorePage extends StatelessWidget {
  const AppleScorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppleScoreController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('APPLE Score'),
          elevation: 0,
          actions: [
            Consumer<AppleScoreController>(
              builder: (context, controller, _) => IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Limpar',
                onPressed: controller.hasAnySelection ? () => controller.reset() : null,
              ),
            ),
          ],
        ),
        body: const _AppleScoreBody(),
      ),
    );
  }
}

class _AppleScoreBody extends StatelessWidget {
  const _AppleScoreBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header com descrição
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A Point Prevalence of Pain Evaluation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sistema de avaliação de dor em animais',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),

        // Formulário e Resultado
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Parâmetros de avaliação
                _ParameterCard(
                  title: 'Atitude / Comportamento',
                  icon: Icons.psychology,
                  descriptions: AppleScoreDescriptions.attitude,
                  onChanged: (value) =>
                      context.read<AppleScoreController>().updateAttitude(value),
                  currentValue: context.watch<AppleScoreController>().score.attitude,
                ),
                const SizedBox(height: 12),
                _ParameterCard(
                  title: 'Comfort / Conforto',
                  icon: Icons.bed,
                  descriptions: AppleScoreDescriptions.comfort,
                  onChanged: (value) =>
                      context.read<AppleScoreController>().updateComfort(value),
                  currentValue: context.watch<AppleScoreController>().score.comfort,
                ),
                const SizedBox(height: 12),
                _ParameterCard(
                  title: 'Postura',
                  icon: Icons.airline_seat_recline_normal,
                  descriptions: AppleScoreDescriptions.posture,
                  onChanged: (value) =>
                      context.read<AppleScoreController>().updatePosture(value),
                  currentValue: context.watch<AppleScoreController>().score.posture,
                ),
                const SizedBox(height: 12),
                _ParameterCard(
                  title: 'Vocalização',
                  icon: Icons.volume_up,
                  descriptions: AppleScoreDescriptions.vocalization,
                  onChanged: (value) =>
                      context.read<AppleScoreController>().updateVocalization(value),
                  currentValue: context.watch<AppleScoreController>().score.vocalization,
                ),
                const SizedBox(height: 12),
                _ParameterCard(
                  title: 'Resposta à Palpação',
                  icon: Icons.touch_app,
                  descriptions: AppleScoreDescriptions.palpation,
                  onChanged: (value) =>
                      context.read<AppleScoreController>().updatePalpation(value),
                  currentValue: context.watch<AppleScoreController>().score.palpation,
                ),
                const SizedBox(height: 24),

                // Card de Resultado
                Consumer<AppleScoreController>(
                  builder: (context, controller, _) => _ResultCard(
                    score: controller.score,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Card para cada parâmetro de avaliação
class _ParameterCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<int, String> descriptions;
  final Function(int) onChanged;
  final int currentValue;

  const _ParameterCard({
    required this.title,
    required this.icon,
    required this.descriptions,
    required this.onChanged,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do parâmetro
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Opções de seleção (0, 1, 2)
            ...descriptions.entries.map((entry) {
              final value = entry.key;
              final description = entry.value;
              final isSelected = currentValue == value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => onChanged(value),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Botão de rádio
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // Score e descrição
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Score: $value',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

/// Card de resultado com score total e interpretação
class _ResultCard extends StatelessWidget {
  final AppleScore score;

  const _ResultCard({required this.score});

  Color _getInterpretationColor(BuildContext context, String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.amber;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interpretationColor = _getInterpretationColor(context, score.interpretationColor);

    return Card(
      elevation: 4,
      color: interpretationColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Score total
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics,
                  size: 32,
                  color: interpretationColor,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score Total',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${score.totalScore}/10',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: interpretationColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 32),

            // Interpretação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: interpretationColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: interpretationColor.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: interpretationColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        score.interpretation.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: interpretationColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    score.recommendation,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Escala visual
            const SizedBox(height: 16),
            _PainScaleBar(score: score.totalScore),
          ],
        ),
      ),
    );
  }
}

/// Barra visual da escala de dor
class _PainScaleBar extends StatelessWidget {
  final int score;

  const _PainScaleBar({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: score == 0 ? Colors.green : Colors.grey.shade300,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 3,
              child: Container(
                height: 8,
                color: score > 0 && score <= 3 ? Colors.amber : Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 4,
              child: Container(
                height: 8,
                color: score > 3 && score <= 7 ? Colors.orange : Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 3,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: score > 7 ? Colors.red : Colors.grey.shade300,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: Theme.of(context).textTheme.labelSmall),
            Text('3', style: Theme.of(context).textTheme.labelSmall),
            Text('7', style: Theme.of(context).textTheme.labelSmall),
            Text('10', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
