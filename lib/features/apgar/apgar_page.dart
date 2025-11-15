import 'package:flutter/material.dart';
import 'models/apgar_parameters.dart';
import 'models/species_config.dart';
import 'widgets/parameter_selector.dart';
import 'widgets/species_selector.dart';
import 'widgets/score_display.dart';

/// Página da Calculadora de Escore Apgar Veterinário
class ApgarPage extends StatefulWidget {
  const ApgarPage({super.key});

  @override
  State<ApgarPage> createState() => _ApgarPageState();
}

class _ApgarPageState extends State<ApgarPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedSpecies;
  SpeciesConfig? _speciesConfig;

  int? _mucousMembraneScore;
  int? _heartRateScore;
  int? _irritabilityScore;
  int? _motilityScore;
  int? _respiratoryScore;

  int? _totalScore;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escore Apgar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Ajuda',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informação inicial
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pets,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Avalie o neonato nos primeiros 5 minutos de vida',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Seleção de espécie
                SpeciesSelector(
                  selectedSpecies: _selectedSpecies,
                  onChanged: _onSpeciesChanged,
                ),

                // Parâmetros dependentes de espécie
                if (_speciesConfig != null) ...[
                  // 1. Cor das mucosas
                  ParameterSelector(
                    label: '1. Cor das Mucosas',
                    helperText: 'Avalie a coloração das gengivas',
                    options: ApgarParameters.mucousMembraneOptions,
                    selectedScore: _mucousMembraneScore,
                    onChanged: (value) {
                      setState(() {
                        _mucousMembraneScore = value;
                        _showResult = false;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione a cor das mucosas';
                      }
                      return null;
                    },
                  ),

                  // 2. Frequência cardíaca (dinâmico por espécie)
                  ParameterSelector(
                    label: '2. ${_speciesConfig!.heartRateLabel}',
                    helperText: 'Ausculte o coração por 15 segundos',
                    options: _speciesConfig!.heartRateOptions,
                    selectedScore: _heartRateScore,
                    onChanged: (value) {
                      setState(() {
                        _heartRateScore = value;
                        _showResult = false;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione a frequência cardíaca';
                      }
                      return null;
                    },
                  ),

                  // 3. Reflexo de irritabilidade
                  ParameterSelector(
                    label: '3. Reflexo de Irritabilidade',
                    helperText: 'Estimule suavemente o filhote',
                    options: ApgarParameters.irritabilityOptions,
                    selectedScore: _irritabilityScore,
                    onChanged: (value) {
                      setState(() {
                        _irritabilityScore = value;
                        _showResult = false;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione o reflexo de irritabilidade';
                      }
                      return null;
                    },
                  ),

                  // 4. Motilidade
                  ParameterSelector(
                    label: '4. Motilidade (Tônus Muscular)',
                    helperText: 'Avalie o movimento dos membros',
                    options: ApgarParameters.motilityOptions,
                    selectedScore: _motilityScore,
                    onChanged: (value) {
                      setState(() {
                        _motilityScore = value;
                        _showResult = false;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione a motilidade';
                      }
                      return null;
                    },
                  ),

                  // 5. Esforços respiratórios (dinâmico por espécie)
                  ParameterSelector(
                    label: '5. ${_speciesConfig!.respiratoryLabel}',
                    helperText: 'Observe a respiração por 15 segundos',
                    options: _speciesConfig!.respiratoryOptions,
                    selectedScore: _respiratoryScore,
                    onChanged: (value) {
                      setState(() {
                        _respiratoryScore = value;
                        _showResult = false;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione o esforço respiratório';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _calculateScore,
                          icon: const Icon(Icons.calculate),
                          label: const Text(
                            'Calcular Escore',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'Limpar',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Resultado
                  if (_showResult && _totalScore != null)
                    ScoreDisplay(
                      totalScore: _totalScore!,
                      showRecommendations: true,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Atualiza a configuração quando a espécie muda
  void _onSpeciesChanged(String? species) {
    setState(() {
      _selectedSpecies = species;
      if (species != null) {
        _speciesConfig = SpeciesConfig.getConfig(species);
        // Reset dos valores dependentes de espécie
        _heartRateScore = null;
        _respiratoryScore = null;
      } else {
        _speciesConfig = null;
      }
      // Reset de outros campos
      _mucousMembraneScore = null;
      _irritabilityScore = null;
      _motilityScore = null;
      _showResult = false;
      _totalScore = null;
    });
  }

  /// Calcula o escore total
  void _calculateScore() {
    if (_formKey.currentState!.validate()) {
      final total = (_mucousMembraneScore ?? 0) +
          (_heartRateScore ?? 0) +
          (_irritabilityScore ?? 0) +
          (_motilityScore ?? 0) +
          (_respiratoryScore ?? 0);

      setState(() {
        _totalScore = total;
        _showResult = true;
      });

      // Scroll para o resultado (kept minimal)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, preencha todos os campos'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Limpa o formulário
  void _clearForm() {
    setState(() {
      _selectedSpecies = null;
      _speciesConfig = null;
      _mucousMembraneScore = null;
      _heartRateScore = null;
      _irritabilityScore = null;
      _motilityScore = null;
      _respiratoryScore = null;
      _totalScore = null;
      _showResult = false;
    });
    _formKey.currentState?.reset();
  }

  /// Mostra diálogo de ajuda
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Sobre o Escore Apgar'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'O Escore Apgar veterinário avalia a vitalidade do neonato nos primeiros minutos de vida.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Parâmetros Avaliados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildHelpItem(context, '1. Cor das mucosas'),
              _buildHelpItem(context, '2. Frequência cardíaca'),
              _buildHelpItem(context, '3. Reflexo de irritabilidade'),
              _buildHelpItem(context, '4. Motilidade/Tônus muscular'),
              _buildHelpItem(context, '5. Esforços respiratórios'),
              const SizedBox(height: 16),
              const Text(
                'Interpretação:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildHelpItem(context, '8-10: Excelente', color: Colors.green),
              _buildHelpItem(context, '6-7: Bom', color: Colors.orange),
              _buildHelpItem(context, '4-5: Regular', color: Colors.deepOrange),
              _buildHelpItem(context, '0-3: Crítico', color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Cada parâmetro recebe pontuação de 0 a 2, totalizando 0 a 10 pontos.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: color ?? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

