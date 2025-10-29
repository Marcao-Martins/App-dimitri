class Intercorrencia {
  DateTime momento;
  String descricao;
  List<String>? medicamentosAdministrados;

  Intercorrencia({
    required this.momento,
    required this.descricao,
    this.medicamentosAdministrados,
  });

  Map<String, dynamic> toJson() => {
        'momento': momento.toIso8601String(),
        'descricao': descricao,
        'medicamentosAdministrados': medicamentosAdministrados,
      };

  factory Intercorrencia.fromJson(Map<String, dynamic> json) => Intercorrencia(
        momento: DateTime.parse(json['momento']),
        descricao: json['descricao'] ?? '',
        medicamentosAdministrados: (json['medicamentosAdministrados'] as List?)?.cast<String>(),
      );
}
