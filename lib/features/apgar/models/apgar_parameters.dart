import 'species_config.dart';

/// Parâmetros clínicos do Escore Apgar
class ApgarParameters {
  // Parâmetros comuns (independentes de espécie)
  static const List<ApgarOption> mucousMembraneOptions = [
    ApgarOption(score: 0, label: 'Cianótica (azulada)', description: 'Hipoxemia grave'),
    ApgarOption(score: 1, label: 'Pálida', description: 'Anemia/Hipoperfusão'),
    ApgarOption(score: 2, label: 'Rósea', description: 'Normal'),
  ];

  static const List<ApgarOption> irritabilityOptions = [
    ApgarOption(score: 0, label: 'Ausente', description: 'Sem resposta'),
    ApgarOption(score: 1, label: 'Fraco', description: 'Resposta mínima'),
    ApgarOption(score: 2, label: 'Forte', description: 'Resposta vigorosa'),
  ];

  static const List<ApgarOption> motilityOptions = [
    ApgarOption(score: 0, label: 'Ausente (flácido)', description: 'Hipotonia'),
    ApgarOption(score: 1, label: 'Fraco (flexão)', description: 'Tônus reduzido'),
    ApgarOption(score: 2, label: 'Forte (movimentos ativos)', description: 'Normal'),
  ];

  /// Interpreta o escore total
  static String interpretScore(int score) {
    if (score >= 8) {
      return 'Excelente - Neonato vigoroso';
    } else if (score >= 6) {
      return 'Bom - Atenção moderada necessária';
    } else if (score >= 4) {
      return 'Regular - Reanimação necessária';
    } else {
      return 'Crítico - Reanimação urgente';
    }
  }

  /// Retorna a cor do resultado baseada no escore
  static int getScoreColor(int score) {
    if (score >= 8) {
      return 0xFF4CAF50; // Verde
    } else if (score >= 6) {
      return 0xFFFFA726; // Laranja
    } else if (score >= 4) {
      return 0xFFFF9800; // Laranja escuro
    } else {
      return 0xFFF44336; // Vermelho
    }
  }

  /// Recomendações por faixa de escore
  static List<String> getRecommendations(int score) {
    if (score >= 8) {
      return [
        '✓ Secar e estimular suavemente',
        '✓ Monitorar temperatura',
        '✓ Permitir amamentação',
      ];
    } else if (score >= 6) {
      return [
        '! Oxigenoterapia por máscara',
        '! Estimulação tátil vigorosa',
        '! Monitoramento frequente',
        '! Manter aquecido',
      ];
    } else if (score >= 4) {
      return [
        '!! Oxigenoterapia imediata',
        '!! Aspirar vias aéreas',
        '!! Estimulação vigorosa',
        '!! Considerar doxapram',
        '!! Monitoramento contínuo',
      ];
    } else {
      return [
        '⚠️ REANIMAÇÃO URGENTE',
        '⚠️ Intubação e ventilação',
        '⚠️ Massagem cardíaca se FC < 60 bpm',
        '⚠️ Adrenalina 0.01-0.02 mg/kg IV',
        '⚠️ Acesso vascular umbilical',
        '⚠️ Suporte térmico intensivo',
      ];
    }
  }
}
