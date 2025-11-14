import 'package:flutter/material.dart';
import '../models/pain_assessment.dart';

class Subscale1Widget extends StatelessWidget {
  final UnespPainAssessment assessment;
  final ValueChanged<UnespPainAssessment> onChanged;

  const Subscale1Widget({super.key, required this.assessment, required this.onChanged});

  Widget _radioRow(BuildContext context, String label, int value, int groupValue, String description) {
    return RadioListTile<int>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      subtitle: Text(description, style: const TextStyle(fontSize: 12)),
      onChanged: (v) {
        // handled outside
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subescala 1 — Alteração Psicomotora', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        _buildItem(context, 'Postura', assessment.posture, (v) {
          final copy = UnespPainAssessment(timestamp: assessment.timestamp,
              posture: v,
              comfort: assessment.comfort,
              activity: assessment.activity,
              attitude: assessment.attitude,
              miscellaneousBehaviors: assessment.miscellaneousBehaviors,
              vocalization: assessment.vocalization,
              abdominalPalpation: assessment.abdominalPalpation,
              affectedAreaPalpation: assessment.affectedAreaPalpation,
              bloodPressure: assessment.bloodPressure,
              appetite: assessment.appetite);
          onChanged(copy);
        }, [
          '0 - Postura normal',
          '1 - Leve alteração postural',
          '2 - Moderada alteração postural',
          '3 - Postura muito alterada / proteção do abdome',
        ]),

        const SizedBox(height: 8),

        _buildItem(context, 'Conforto', assessment.comfort, (v) {
          final copy = UnespPainAssessment(timestamp: assessment.timestamp,
              posture: assessment.posture,
              comfort: v,
              activity: assessment.activity,
              attitude: assessment.attitude,
              miscellaneousBehaviors: assessment.miscellaneousBehaviors,
              vocalization: assessment.vocalization,
              abdominalPalpation: assessment.abdominalPalpation,
              affectedAreaPalpation: assessment.affectedAreaPalpation,
              bloodPressure: assessment.bloodPressure,
              appetite: assessment.appetite);
          onChanged(copy);
        }, [
          '0 - Conforto normal',
          '1 - Leve desconforto',
          '2 - Moderado desconforto',
          '3 - Incômodo severo / incapacidade de se acomodar',
        ]),

        const SizedBox(height: 8),

        _buildItem(context, 'Atividade', assessment.activity, (v) {
          final copy = UnespPainAssessment(timestamp: assessment.timestamp,
              posture: assessment.posture,
              comfort: assessment.comfort,
              activity: v,
              attitude: assessment.attitude,
              miscellaneousBehaviors: assessment.miscellaneousBehaviors,
              vocalization: assessment.vocalization,
              abdominalPalpation: assessment.abdominalPalpation,
              affectedAreaPalpation: assessment.affectedAreaPalpation,
              bloodPressure: assessment.bloodPressure,
              appetite: assessment.appetite);
          onChanged(copy);
        }, [
          '0 - Atividade normal',
          '1 - Leve diminuição',
          '2 - Moderada diminuição',
          '3 - Inatividade / imobilidade',
        ]),

        const SizedBox(height: 8),

        _buildItem(context, 'Atitude', assessment.attitude, (v) {
          final copy = UnespPainAssessment(timestamp: assessment.timestamp,
              posture: assessment.posture,
              comfort: assessment.comfort,
              activity: assessment.activity,
              attitude: v,
              miscellaneousBehaviors: assessment.miscellaneousBehaviors,
              vocalization: assessment.vocalization,
              abdominalPalpation: assessment.abdominalPalpation,
              affectedAreaPalpation: assessment.affectedAreaPalpation,
              bloodPressure: assessment.bloodPressure,
              appetite: assessment.appetite);
          onChanged(copy);
        }, [
          '0 - Atitude normal',
          '1 - Leve alteração de atitude',
          '2 - Moderada alteração de atitude',
          '3 - Atitude defensiva / agressiva',
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
