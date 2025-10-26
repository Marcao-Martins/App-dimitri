/// Modelo de Histórico de Cálculo
/// Armazena informações sobre cálculos anteriores
class DoseCalculation {
  final String id;
  final DateTime timestamp;
  final String medicationName;
  final double weightKg;
  final String species;
  final double calculatedDose;
  final String unit;
  final bool wasSafe;
  
  DoseCalculation({
    required this.id,
    required this.timestamp,
    required this.medicationName,
    required this.weightKg,
    required this.species,
    required this.calculatedDose,
    required this.unit,
    required this.wasSafe,
  });
  
  /// Converte para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'medicationName': medicationName,
      'weightKg': weightKg,
      'species': species,
      'calculatedDose': calculatedDose,
      'unit': unit,
      'wasSafe': wasSafe,
    };
  }
  
  /// Cria instância a partir de Map
  factory DoseCalculation.fromJson(Map<String, dynamic> json) {
    return DoseCalculation(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      medicationName: json['medicationName'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      species: json['species'] as String,
      calculatedDose: (json['calculatedDose'] as num).toDouble(),
      unit: json['unit'] as String,
      wasSafe: json['wasSafe'] as bool,
    );
  }
  
  /// Formata a data para exibição
  String getFormattedDate() {
    return '${timestamp.day.toString().padLeft(2, '0')}/'
           '${timestamp.month.toString().padLeft(2, '0')}/'
           '${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
