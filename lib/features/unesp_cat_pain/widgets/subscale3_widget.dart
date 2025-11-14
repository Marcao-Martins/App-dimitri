import 'package:flutter/material.dart';
import '../models/pain_assessment.dart';

class Subscale3Widget extends StatelessWidget {
  final UnespPainAssessment assessment;
  final ValueChanged<UnespPainAssessment> onChanged;

  const Subscale3Widget({super.key, required this.assessment, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subescala 3 — Variáveis Fisiológicas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        _buildItem(context, 'Pressão arterial', assessment.bloodPressure, (v) {
          final copy = UnespPainAssessment(
            timestamp: assessment.timestamp,
            posture: assessment.posture,
            comfort: assessment.comfort,
            activity: assessment.activity,
            attitude: assessment.attitude,
            miscellaneousBehaviors: assessment.miscellaneousBehaviors,
            vocalization: assessment.vocalization,
            abdominalPalpation: assessment.abdominalPalpation,
            affectedAreaPalpation: assessment.affectedAreaPalpation,
            bloodPressure: v,
            appetite: assessment.appetite,
          );
          onChanged(copy);
        }, [
          '0 - Pressão normal',
          '1 - Leve aumento',
          '2 - Aumento moderado',
          '3 - Taquicardia / hipertensão evidente',
        ]),

        const SizedBox(height: 8),

        _buildItem(context, 'Apetite', assessment.appetite, (v) {
          final copy = UnespPainAssessment(
            timestamp: assessment.timestamp,
            posture: assessment.posture,
            comfort: assessment.comfort,
            activity: assessment.activity,
            attitude: assessment.attitude,
            miscellaneousBehaviors: assessment.miscellaneousBehaviors,
            vocalization: assessment.vocalization,
            abdominalPalpation: assessment.abdominalPalpation,
            affectedAreaPalpation: assessment.affectedAreaPalpation,
            bloodPressure: assessment.bloodPressure,
            appetite: v,
          );
          onChanged(copy);
        }, [
          '0 - Apetite normal',
          '1 - Leve diminuição do apetite',
          '2 - Diminuição moderada do apetite',
          '3 - Não aceita alimento / anorexia',
        ]),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title, int groupValue, ValueChanged<int> onSelect, List<String> descriptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: RadioListTile<int>(
                title: Text('$i'),
                value: i,
                groupValue: groupValue,
                subtitle: Text(descriptions[i], style: const TextStyle(fontSize: 11)),
                onChanged: (v) => onSelect(v ?? 0),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
