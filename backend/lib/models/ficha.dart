// lib/models/ficha.dart
// Modelo de dados para fichas veterinárias
// Cada usuário possui uma coleção de fichas de seus animais

enum AnimalType {
  canino,
  felino,
  equino,
  bovino,
  suino,
  ovino,
  caprino,
  outro;

  /// Converte string para AnimalType
  static AnimalType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'canino':
        return AnimalType.canino;
      case 'felino':
        return AnimalType.felino;
      case 'equino':
        return AnimalType.equino;
      case 'bovino':
        return AnimalType.bovino;
      case 'suino':
        return AnimalType.suino;
      case 'ovino':
        return AnimalType.ovino;
      case 'caprino':
        return AnimalType.caprino;
      default:
        return AnimalType.outro;
    }
  }

  /// Converte para string
  String toJson() => name;
}

enum AnimalSex {
  macho,
  femea;

  /// Converte string para AnimalSex
  static AnimalSex fromString(String sex) {
    switch (sex.toLowerCase()) {
      case 'macho':
        return AnimalSex.macho;
      case 'femea':
        return AnimalSex.femea;
      default:
        return AnimalSex.macho;
    }
  }

  /// Converte para string
  String toJson() => name;
}

class Ficha {
  final String id; // UUID v4
  final String userId; // Foreign Key -> users.id
  final String animalName; // Nome do animal
  final AnimalType animalType; // Tipo do animal
  final String breed; // Raça
  final AnimalSex sex; // Sexo
  final double weight; // Peso em kg
  final DateTime? birthDate; // Data de nascimento (opcional)
  final String? microchipNumber; // Número do microchip (opcional)
  final String? ownerName; // Nome do proprietário (opcional)
  final String? ownerPhone; // Telefone do proprietário (opcional)
  final String? observations; // Observações gerais
  final DateTime createdAt; // Data de criação da ficha
  final DateTime updatedAt; // Data da última atualização
  final DateTime? deletedAt; // Soft delete

  Ficha({
    required this.id,
    required this.userId,
    required this.animalName,
    required this.animalType,
    required this.breed,
    required this.sex,
    required this.weight,
    this.birthDate,
    this.microchipNumber,
    this.ownerName,
    this.ownerPhone,
    this.observations,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria uma instância de Ficha a partir de um Map (JSON)
  factory Ficha.fromJson(Map<String, dynamic> json) {
    return Ficha(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      animalName: json['animalName']?.toString() ?? json['animal_name']?.toString() ?? '',
      animalType: AnimalType.fromString(
        json['animalType']?.toString() ?? json['animal_type']?.toString() ?? 'outro',
      ),
      breed: json['breed']?.toString() ?? '',
      sex: AnimalSex.fromString(json['sex']?.toString() ?? 'macho'),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      birthDate: json['birthDate'] != null || json['birth_date'] != null
          ? DateTime.parse((json['birthDate'] ?? json['birth_date']).toString())
          : null,
      microchipNumber: json['microchipNumber']?.toString() ?? json['microchip_number']?.toString(),
      ownerName: json['ownerName']?.toString() ?? json['owner_name']?.toString(),
      ownerPhone: json['ownerPhone']?.toString() ?? json['owner_phone']?.toString(),
      observations: json['observations']?.toString(),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse((json['createdAt'] ?? json['created_at']).toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse((json['updatedAt'] ?? json['updated_at']).toString())
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null || json['deleted_at'] != null
          ? DateTime.parse((json['deletedAt'] ?? json['deleted_at']).toString())
          : null,
    );
  }

  /// Converte a instância de Ficha para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'animalName': animalName,
      'animalType': animalType.toJson(),
      'breed': breed,
      'sex': sex.toJson(),
      'weight': weight,
      'birthDate': birthDate?.toIso8601String(),
      'microchipNumber': microchipNumber,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'observations': observations,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  /// Converte para JSON com snake_case (para MySQL)
  Map<String, dynamic> toJsonSnakeCase() {
    return {
      'id': id,
      'user_id': userId,
      'animal_name': animalName,
      'animal_type': animalType.toJson(),
      'breed': breed,
      'sex': sex.toJson(),
      'weight': weight,
      'birth_date': birthDate?.toIso8601String(),
      'microchip_number': microchipNumber,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'observations': observations,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia da instância com campos atualizados
  Ficha copyWith({
    String? id,
    String? userId,
    String? animalName,
    AnimalType? animalType,
    String? breed,
    AnimalSex? sex,
    double? weight,
    DateTime? birthDate,
    String? microchipNumber,
    String? ownerName,
    String? ownerPhone,
    String? observations,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Ficha(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      animalName: animalName ?? this.animalName,
      animalType: animalType ?? this.animalType,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      observations: observations ?? this.observations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Verifica se a ficha foi deletada
  bool get isDeleted => deletedAt != null;

  /// Calcula a idade aproximada do animal em anos
  int? get ageInYears {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Retorna descrição legível do animal
  String get animalDescription {
    return '$animalName ($breed ${sex.name}, ${weight}kg)';
  }
}
