import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../apple_full_controller.dart';

class MortalityCalculator extends StatelessWidget {
  const MortalityCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppleFullController>(context);
    final score = controller.totalScore;
    final prob = controller.mortalityProbability * 100;

    String fmt(double v) => v.isNaN ? '-' : v.toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Resultado', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Score total: $score', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 6),
            Text('Probabilidade de mortalidade: ${fmt(prob)} %', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await controller.saveToHistory();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo no histórico')));
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
