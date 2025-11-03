/// Modelo de Medicamento Veterinário
/// Contém informações completas sobre doses, indicações e contraindicações
class Medication {
  final String id;
  final String name; // Nome do fármaco
  final double minDose; // Dose mínima em mg/kg
  final double maxDose; // Dose máxima em mg/kg
  final String unit; // Unidade (mg/kg, mcg/kg, etc)
  final List<String> species; // Espécies compatíveis
  final String category; // Classe farmacológica
  
  // Campos adicionais do CSV
  final String? tradeName; // Nome comercial
  final String? mechanismOfAction; // Mecanismo de ação
  final String? dogDosage; // Posologia para cães
  final String? catDosage; // Posologia para gatos
  final String? cri; // Infusão venosa contínua (CRI/IVC)
  final String? comments; // Comentários
  final String? references; // Referências bibliográficas
  final String? link; // Link para o post original
  
  final String? indications; // Indicações de uso
  final String? contraindications; // Contraindicações
  final String? precautions; // Precauções especiais
  final String? description; // Descrição geral
  
  Medication({
    required this.id,
    required this.name,
    required this.minDose,
    required this.maxDose,
    required this.unit,
    required this.species,
    required this.category,
    this.tradeName,
    this.mechanismOfAction,
    this.dogDosage,
    this.catDosage,
    this.cri,
    this.comments,
    this.references,
    this.link,
    this.indications,
    this.contraindications,
    this.precautions,
    this.description,
  });
  
  /// Calcula a dose recomendada baseada no peso do animal
  double calculateDose(double weightKg) {
    // Retorna a dose média da faixa recomendada
    return (minDose + maxDose) / 2 * weightKg;
  }
  
  /// Verifica se a dose está dentro da faixa segura
  bool isDoseSafe(double dose, double weightKg) {
    final minSafeDose = minDose * weightKg;
    final maxSafeDose = maxDose * weightKg;
    return dose >= minSafeDose && dose <= maxSafeDose;
  }
  
  /// Retorna a faixa de dose segura para um peso específico
  Map<String, double> getSafeDoseRange(double weightKg) {
    return {
      'min': minDose * weightKg,
      'max': maxDose * weightKg,
    };
  }
  
  /// Verifica se o medicamento é compatível com a espécie
  bool isCompatibleWithSpecies(String animalSpecies) {
    return species.contains(animalSpecies);
  }
  
  /// Converte para Map (útil para persistência)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minDose': minDose,
      'maxDose': maxDose,
      'unit': unit,
      'species': species,
      'category': category,
      'tradeName': tradeName,
      'mechanismOfAction': mechanismOfAction,
      'dogDosage': dogDosage,
      'catDosage': catDosage,
      'cri': cri,
      'comments': comments,
      'references': references,
      'link': link,
      'indications': indications,
      'contraindications': contraindications,
      'precautions': precautions,
      'description': description,
    };
  }
  
  /// Cria instância a partir de Map
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      minDose: (json['minDose'] as num).toDouble(),
      maxDose: (json['maxDose'] as num).toDouble(),
      unit: json['unit'] as String,
      species: List<String>.from(json['species'] as List),
      category: json['category'] as String,
      tradeName: json['tradeName'] as String?,
      mechanismOfAction: json['mechanismOfAction'] as String?,
      dogDosage: json['dogDosage'] as String?,
      catDosage: json['catDosage'] as String?,
      cri: json['cri'] as String?,
      comments: json['comments'] as String?,
      references: json['references'] as String?,
      link: json['link'] as String?,
      indications: json['indications'] as String?,
      contraindications: json['contraindications'] as String?,
      precautions: json['precautions'] as String?,
      description: json['description'] as String?,
    );
  }
  
  @override
  String toString() {
    return '$name ($minDose-$maxDose $unit)';
  }
}
