import 'package:flutter/material.dart';
import '../models/pain_assessment.dart';

class Subscale2Widget extends StatelessWidget {
  final UnespPainAssessment assessment;
  final ValueChanged<UnespPainAssessment> onChanged;

  const Subscale2Widget({super.key, required this.assessment, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subescala 2 — Expressão da Dor', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        _buildItem(context, 'Miscelânea de comportamentos', assessment.miscellaneousBehaviors, (v) {
          final copy = _copyWith(assessment, miscellaneousBehaviors: v);
          onChanged(copy);
        }, [
          '0 - Sem comportamentos anormais',
          '1 - Leves comportamentos anormais',
          '2 - Moderados comportamentos anormais',
          '3 - Comportamentos evidentes de dor',
        ]),

        const SizedBox(height: 8),

        _buildItem(context, 'Vocalização', assessment.vocalization, (v) {
          final copy = _copyWith(assessment, vocalization: v);
          onChanged(copy);
        }, [
          '0 - Sem vocalização',
          '1 - Vocalização esporádica',
          '2 - Vocalização frequente',
          '3 - Vocalização intensa',
        ]),

        const SizedBox(height: 8),

        _buildItem(context, 'Reação à palpação do abdome/flanco', assessment.abdominalPalpation, (v) {
          final copy = _copyWith(assessment, abdominalPalpation: v);
          onChanged(copy);
        }, [
          '0 - Sem reação',
          '1 - Leve reação',
          '2 - Reação moderada',
          '3 - Reação intensa / agressiva',
        ]),

        const SizedBox(height: 8),

        _buildItem(context, 'Reação à palpação da área afetada', assessment.affectedAreaPalpation, (v) {
          final copy = _copyWith(assessment, affectedAreaPalpation: v);
          onChanged(copy);
        }, [
          '0 - Sem reação',
          '1 - Leve sensibilidade',
          '2 - Sensibilidade moderada',
          '3 - Sensibilidade intensa / defesa',
        ]),
      ],
    );
  }

  UnespPainAssessment _copyWith(UnespPainAssessment a, {int? miscellaneousBehaviors, int? vocalization, int? abdominalPalpation, int? affectedAreaPalpation}) {
    return UnespPainAssessment(
      timestamp: a.timestamp,
      posture: a.posture,
      comfort: a.comfort,
      activity: a.activity,
      attitude: a.attitude,
      miscellaneousBehaviors: miscellaneousBehaviors ?? a.miscellaneousBehaviors,
      vocalization: vocalization ?? a.vocalization,
      abdominalPalpation: abdominalPalpation ?? a.abdominalPalpation,
      affectedAreaPalpation: affectedAreaPalpation ?? a.affectedAreaPalpation,
      bloodPressure: a.bloodPressure,
      appetite: a.appetite,
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
