class Medicacao {
  String nome;
  String? dose;
  String? via;
  DateTime? hora;

  Medicacao({
    required this.nome,
    this.dose,
    this.via,
    this.hora,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'dose': dose,
        'via': via,
        'hora': hora?.toIso8601String(),
      };

  factory Medicacao.fromJson(Map<String, dynamic> json) => Medicacao(
        nome: json['nome'] ?? '',
        dose: json['dose'],
        via: json['via'],
        hora: json['hora'] != null ? DateTime.parse(json['hora']) : null,
      );
}
