class UnespPainAssessment {
  // Timestamp
  final DateTime timestamp;
  String? animalName;

  // Subescala 1
  int posture;
  int comfort;
  int activity;
  int attitude;

  // Subescala 2
  int miscellaneousBehaviors;
  int vocalization;
  int abdominalPalpation;
  int affectedAreaPalpation;

  // Subescala 3
  int bloodPressure;
  int appetite;

  UnespPainAssessment({
    DateTime? timestamp,
    this.animalName,
    this.posture = 0,
    this.comfort = 0,
    this.activity = 0,
    this.attitude = 0,
    this.miscellaneousBehaviors = 0,
    this.vocalization = 0,
    this.abdominalPalpation = 0,
    this.affectedAreaPalpation = 0,
    this.bloodPressure = 0,
    this.appetite = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  // Getters
  int get subscale1Total => posture + comfort + activity + attitude;
  int get subscale2Total => miscellaneousBehaviors + vocalization + abdominalPalpation + affectedAreaPalpation;
  int get subscale3Total => bloodPressure + appetite;
  int get totalScore => subscale1Total + subscale2Total + subscale3Total;

  String get analgesicRecommendation {
    if (totalScore >= 8) return 'ANALGESIA RECOMENDADA - Escala completa';
    if (subscale1Total >= 4) return 'ANALGESIA RECOMENDADA - Subescala 1';
    if (subscale2Total >= 3) return 'ANALGESIA RECOMENDADA - Subescala 2';
    if (subscale1Total + subscale2Total >= 7) return 'ANALGESIA RECOMENDADA - Subescalas 1+2';
    return 'Monitorar - analgesia pode não ser necessária';
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'animalName': animalName ?? '',
      'posture': posture,
      'comfort': comfort,
      'activity': activity,
      'attitude': attitude,
      'miscellaneousBehaviors': miscellaneousBehaviors,
      'vocalization': vocalization,
      'abdominalPalpation': abdominalPalpation,
      'affectedAreaPalpation': affectedAreaPalpation,
      'bloodPressure': bloodPressure,
      'appetite': appetite,
      'subscale1Total': subscale1Total,
      'subscale2Total': subscale2Total,
      'subscale3Total': subscale3Total,
      'totalScore': totalScore,
      'recommendation': analgesicRecommendation,
    };
  }

  String toCsv() {
    final m = toMap();
    final headers = m.keys.join(',');
    final values = m.values.map((v) => '"$v"').join(',');
    return '$headers\n$values';
  }

  factory UnespPainAssessment.fromMap(Map<String, dynamic> m) {
    DateTime ts;
    try {
      ts = DateTime.parse(m['timestamp'] as String);
    } catch (_) {
      ts = DateTime.now();
    }
    return UnespPainAssessment(
      timestamp: ts,
      animalName: (m['animalName'] as String?)?.isEmpty ?? true ? null : m['animalName'] as String?,
      posture: (m['posture'] as num?)?.toInt() ?? 0,
      comfort: (m['comfort'] as num?)?.toInt() ?? 0,
      activity: (m['activity'] as num?)?.toInt() ?? 0,
      attitude: (m['attitude'] as num?)?.toInt() ?? 0,
      miscellaneousBehaviors: (m['miscellaneousBehaviors'] as num?)?.toInt() ?? 0,
      vocalization: (m['vocalization'] as num?)?.toInt() ?? 0,
      abdominalPalpation: (m['abdominalPalpation'] as num?)?.toInt() ?? 0,
      affectedAreaPalpation: (m['affectedAreaPalpation'] as num?)?.toInt() ?? 0,
      bloodPressure: (m['bloodPressure'] as num?)?.toInt() ?? 0,
      appetite: (m['appetite'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() => 'UFEPS(${timestamp.toIso8601String()}) total=$totalScore';
}
