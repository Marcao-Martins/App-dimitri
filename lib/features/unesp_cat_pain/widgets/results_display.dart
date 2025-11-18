import 'package:flutter/material.dart';
import '../models/pain_assessment.dart';

class ResultsDisplay extends StatelessWidget {
  final UnespPainAssessment assessment;

  const ResultsDisplay({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final s1 = assessment.subscale1Total;
    final s2 = assessment.subscale2Total;
    final s3 = assessment.subscale3Total;
    final total = assessment.totalScore;

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Resultados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Subescala 1:')),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text('$s1 / 12', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Subescala 2:')),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text('$s2 / 12', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Subescala 3:')),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text('$s3 / 6', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Total:')),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text('$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 20),
              child: Text(
                'Recomendação: ${assessment.analgesicRecommendation}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            if (total >= 8 || s1 >= 4 || s2 >= 3 || (s1 + s2) >= 7)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Atenção: critério(s) analgésico(s) atingido(s)', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
