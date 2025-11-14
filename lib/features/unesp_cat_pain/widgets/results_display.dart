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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subescala 1:'),
                Text('$s1 / 12', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subescala 2:'),
                Text('$s2 / 12', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subescala 3:'),
                Text('$s3 / 6', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:'),
                Text('$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Recomendação: ${assessment.analgesicRecommendation}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
