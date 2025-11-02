class Intercorrencia {
  DateTime momento;
  String descricao;
  String gravidade; // leve, moderada, grave
  List<String>? medicamentosAdministrados;

  Intercorrencia({
    required this.momento,
    required this.descricao,
    this.gravidade = 'leve',
    this.medicamentosAdministrados,
  });

  Map<String, dynamic> toJson() => {
        'momento': momento.toIso8601String(),
        'descricao': descricao,
        'gravidade': gravidade,
        'medicamentosAdministrados': medicamentosAdministrados,
      };

  factory Intercorrencia.fromJson(Map<String, dynamic> json) => Intercorrencia(
        momento: DateTime.parse(json['momento']),
        descricao: json['descricao'] ?? '',
        gravidade: json['gravidade'] ?? 'leve',
        medicamentosAdministrados: (json['medicamentosAdministrados'] as List?)?.cast<String>(),
      );
}
