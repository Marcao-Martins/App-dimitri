/// Modelo para cálculo do APPLE Score (A Point Prevalence of Pain Evaluation)
/// Sistema de avaliação de dor em animais
class AppleScore {
  int attitude;
  int comfort;
  int posture;
  int vocalization;
  int palpation;

  AppleScore({
    this.attitude = 0,
    this.comfort = 0,
    this.posture = 0,
    this.vocalization = 0,
    this.palpation = 0,
  });

  /// Score total (soma de todos os parâmetros)
  int get totalScore =>
      attitude + comfort + posture + vocalization + palpation;

  /// Interpretação do resultado baseado no score total
  String get interpretation {
    if (totalScore == 0) return 'Sem dor aparente';
    if (totalScore <= 3) return 'Dor leve';
    if (totalScore <= 7) return 'Dor moderada';
    return 'Dor severa';
  }

  /// Cor para representação visual do resultado
  String get interpretationColor {
    if (totalScore == 0) return 'green';
    if (totalScore <= 3) return 'yellow';
    if (totalScore <= 7) return 'orange';
    return 'red';
  }

  /// Recomendação clínica baseada no score
  String get recommendation {
    if (totalScore == 0) return 'Monitoramento contínuo';
    if (totalScore <= 3) return 'Considerar analgesia preventiva';
    if (totalScore <= 7) return 'Analgesia recomendada';
    return 'Analgesia urgente necessária';
  }

  /// Reseta todos os valores para zero
  void reset() {
    attitude = 0;
    comfort = 0;
    posture = 0;
    vocalization = 0;
    palpation = 0;
  }

  /// Copia o score atual
  AppleScore copyWith({
    int? attitude,
    int? comfort,
    int? posture,
    int? vocalization,
    int? palpation,
  }) {
    return AppleScore(
      attitude: attitude ?? this.attitude,
      comfort: comfort ?? this.comfort,
      posture: posture ?? this.posture,
      vocalization: vocalization ?? this.vocalization,
      palpation: palpation ?? this.palpation,
    );
  }
}

/// Descrições detalhadas para cada parâmetro e seus valores
class AppleScoreDescriptions {
  // Atitude/Comportamento
  static const Map<int, String> attitude = {
    0: 'Normal, alerta, responsivo',
    1: 'Discretamente deprimido ou ansioso',
    2: 'Muito deprimido, agressivo ou não responsivo',
  };

  // Comfort/Conforto
  static const Map<int, String> comfort = {
    0: 'Confortável e relaxado',
    1: 'Inquieto, não encontra posição confortável',
    2: 'Tenso, rígido, relutante em se mover',
  };

  // Postura
  static const Map<int, String> posture = {
    0: 'Postura normal',
    1: 'Postura anormal (arqueada, encolhida)',
    2: 'Postura muito anormal, protegendo área dolorosa',
  };

  // Vocalização
  static const Map<int, String> vocalization = {
    0: 'Sem vocalização',
    1: 'Vocalização ocasional ou quando tocado',
    2: 'Vocalização frequente ou contínua',
  };

  // Resposta à palpação
  static const Map<int, String> palpation = {
    0: 'Sem reação à palpação',
    1: 'Reage à palpação da área dolorosa',
    2: 'Reage violentamente, não permite palpação',
  };
}
