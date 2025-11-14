import 'package:flutter/material.dart';
import 'models/pain_assessment.dart';
import 'unesp_controller.dart';
import 'widgets/subscale1_widget.dart';
import 'widgets/subscale2_widget.dart';
import 'widgets/subscale3_widget.dart';
import 'widgets/results_display.dart';

class UnespCatPainPage extends StatefulWidget {
  const UnespCatPainPage({super.key});

  @override
  State<UnespCatPainPage> createState() => _UnespCatPainPageState();
}

class _UnespCatPainPageState extends State<UnespCatPainPage> {
  final UnespController _controller = UnespController();
  UnespPainAssessment _assessment = UnespPainAssessment();

  @override
  void initState() {
    super.initState();
    // Carrega histórico persistido
    _controller.loadHistory().then((_) {
      setState(() {});
    });
  }

  void _update(UnespPainAssessment a) {
    setState(() {
      _assessment = a;
    });
  }

  Future<void> _promptAndSave() async {
    final controller = TextEditingController();
    final name = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salvar avaliação'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nome do animal', hintText: 'Digite o nome do animal (opcional)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Salvar')),
          ],
        );
      },
    );

    if (name == null) return; // usuário cancelou

    final saved = UnespPainAssessment(
      timestamp: DateTime.now(),
      animalName: name.isEmpty ? null : name,
      posture: _assessment.posture,
      comfort: _assessment.comfort,
      activity: _assessment.activity,
      attitude: _assessment.attitude,
      miscellaneousBehaviors: _assessment.miscellaneousBehaviors,
      vocalization: _assessment.vocalization,
      abdominalPalpation: _assessment.abdominalPalpation,
      affectedAreaPalpation: _assessment.affectedAreaPalpation,
      bloodPressure: _assessment.bloodPressure,
      appetite: _assessment.appetite,
    );

    await _controller.saveAssessment(saved);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação salva no histórico')));
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escala UNESP-Botucatu (UFEPS) - Gatos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accordion / ExpansionTiles for subscales
            ExpansionTile(
              initiallyExpanded: true,
              title: const Text('Subescala 1 — Alteração Psicomotora'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Subscale1Widget(assessment: _assessment, onChanged: _update),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Subescala 2 — Expressão da Dor'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Subscale2Widget(assessment: _assessment, onChanged: _update),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Subescala 3 — Variáveis Fisiológicas'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Subscale3Widget(assessment: _assessment, onChanged: _update),
                ),
              ],
            ),

            const SizedBox(height: 12),
            ResultsDisplay(assessment: _assessment),

            const SizedBox(height: 12),
            ElevatedButton(onPressed: _promptAndSave, child: const Text('Salvar no histórico')),
            const SizedBox(height: 8),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_controller.history.isEmpty)
              const Text('Nenhuma avaliação registrada.'),
            if (_controller.history.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final item = _controller.history[index];
                  final displayName = (item.animalName != null && item.animalName!.isNotEmpty) ? item.animalName! : 'Sem nome';
                  return Card(
                    child: ListTile(
                      title: Text('$displayName - ${item.timestamp.toLocal()}'),
                      subtitle: Text('Total: ${item.totalScore} | ${item.analgesicRecommendation}'),
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('$displayName — Resultado'),
                              content: SingleChildScrollView(child: ResultsDisplay(assessment: item)),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar')),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
            // Disclaimer / educational note
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Nota metodológica', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Esta ferramenta implementa a Escala UNESP-Botucatu (UFEPS) para avaliação de dor em gatos. É uma ferramenta auxiliar e não substitui julgamento clínico. Use protocolos institucionais ao tomar decisões sobre analgesia.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
