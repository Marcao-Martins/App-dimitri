/// Modelo de Item do Checklist Pré-Operatório
/// Representa cada verificação necessária antes da cirurgia
class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final String category; // Ex: "Paciente", "Equipamento", "Medicação"
  final bool isCritical; // Item crítico que não pode ser pulado
  bool isCompleted;
  
  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isCritical = false,
    this.isCompleted = false,
  });
  
  /// Marca/desmarca o item
  void toggle() {
    isCompleted = !isCompleted;
  }
  
  /// Converte para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCritical': isCritical,
      'isCompleted': isCompleted,
    };
  }
  
  /// Cria instância a partir de Map
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      isCritical: json['isCritical'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
  
  /// Cria uma cópia com valores atualizados
  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCritical,
    bool? isCompleted,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCritical: isCritical ?? this.isCritical,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Modelo completo do Checklist Pré-Operatório
class PreOpChecklist {
  final String id;
  final DateTime createdAt;
  final String patientName;
  final String species;
  final double weightKg;
  final String asaClassification;
  final DateTime? fastingStartTime;
  final List<ChecklistItem> items;
  
  PreOpChecklist({
    required this.id,
    required this.createdAt,
    required this.patientName,
    required this.species,
    required this.weightKg,
    required this.asaClassification,
    this.fastingStartTime,
    required this.items,
  });
  
  /// Calcula o progresso do checklist (0.0 a 1.0)
  double get progress {
    if (items.isEmpty) return 0.0;
    final completedCount = items.where((item) => item.isCompleted).length;
    return completedCount / items.length;
  }
  
  /// Verifica se todos os itens críticos foram completados
  bool get criticalItemsCompleted {
    final criticalItems = items.where((item) => item.isCritical);
    return criticalItems.every((item) => item.isCompleted);
  }
  
  /// Verifica se o checklist está completo
  bool get isComplete {
    return items.every((item) => item.isCompleted);
  }
  
  /// Calcula o tempo de jejum em horas
  Duration? get fastingDuration {
    if (fastingStartTime == null) return null;
    return DateTime.now().difference(fastingStartTime!);
  }
  
  /// Converte para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'patientName': patientName,
      'species': species,
      'weightKg': weightKg,
      'asaClassification': asaClassification,
      'fastingStartTime': fastingStartTime?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
  
  /// Cria instância a partir de Map
  factory PreOpChecklist.fromJson(Map<String, dynamic> json) {
    return PreOpChecklist(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      patientName: json['patientName'] as String,
      species: json['species'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      asaClassification: json['asaClassification'] as String,
      fastingStartTime: json['fastingStartTime'] != null
          ? DateTime.parse(json['fastingStartTime'] as String)
          : null,
      items: (json['items'] as List)
          .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
