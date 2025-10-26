/// Modelo de Paciente Animal
/// Armazena informações do animal que está sendo atendido
class AnimalPatient {
  final String id;
  final String name;
  final String species; // Canino, Felino, Equino, Bovino
  final String? breed; // Raça (opcional)
  final double weightKg;
  final int? ageYears;
  final int? ageMonths;
  final String? gender; // Macho, Fêmea
  final String? medicalHistory; // Histórico médico
  final List<String>? allergies; // Alergias conhecidas
  final String? currentMedications; // Medicações atuais
  final DateTime? lastMealTime; // Última refeição
  
  AnimalPatient({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.weightKg,
    this.ageYears,
    this.ageMonths,
    this.gender,
    this.medicalHistory,
    this.allergies,
    this.currentMedications,
    this.lastMealTime,
  });
  
  /// Retorna a idade formatada
  String get formattedAge {
    if (ageYears == null && ageMonths == null) return 'Idade não informada';
    if (ageYears != null && ageYears! > 0) {
      return '$ageYears ano${ageYears! > 1 ? 's' : ''}';
    }
    if (ageMonths != null) {
      return '$ageMonths mês${ageMonths! > 1 ? 'es' : ''}';
    }
    return 'Idade não informada';
  }
  
  /// Calcula o tempo de jejum
  Duration? get fastingTime {
    if (lastMealTime == null) return null;
    return DateTime.now().difference(lastMealTime!);
  }
  
  /// Verifica se tem alergias
  bool get hasAllergies {
    return allergies != null && allergies!.isNotEmpty;
  }
  
  /// Converte para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'weightKg': weightKg,
      'ageYears': ageYears,
      'ageMonths': ageMonths,
      'gender': gender,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'lastMealTime': lastMealTime?.toIso8601String(),
    };
  }
  
  /// Cria instância a partir de Map
  factory AnimalPatient.fromJson(Map<String, dynamic> json) {
    return AnimalPatient(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      weightKg: (json['weightKg'] as num).toDouble(),
      ageYears: json['ageYears'] as int?,
      ageMonths: json['ageMonths'] as int?,
      gender: json['gender'] as String?,
      medicalHistory: json['medicalHistory'] as String?,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : null,
      currentMedications: json['currentMedications'] as String?,
      lastMealTime: json['lastMealTime'] != null
          ? DateTime.parse(json['lastMealTime'] as String)
          : null,
    );
  }
  
  /// Cria uma cópia com valores atualizados
  AnimalPatient copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    double? weightKg,
    int? ageYears,
    int? ageMonths,
    String? gender,
    String? medicalHistory,
    List<String>? allergies,
    String? currentMedications,
    DateTime? lastMealTime,
  }) {
    return AnimalPatient(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      weightKg: weightKg ?? this.weightKg,
      ageYears: ageYears ?? this.ageYears,
      ageMonths: ageMonths ?? this.ageMonths,
      gender: gender ?? this.gender,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      lastMealTime: lastMealTime ?? this.lastMealTime,
    );
  }
}
