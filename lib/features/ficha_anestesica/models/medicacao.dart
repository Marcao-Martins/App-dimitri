class Medicacao {
  String nome;
  String? dose;
  String? via;
  DateTime? hora;
  String? tecnica; // NOVO CAMPO (opcional)

  Medicacao({
    required this.nome,
    this.dose,
    this.via,
    this.hora,
    this.tecnica,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'dose': dose,
        'via': via,
        'hora': hora?.toIso8601String(),
        'tecnica': tecnica,
      };

  factory Medicacao.fromJson(Map<String, dynamic> json) => Medicacao(
        nome: json['nome'] ?? '',
        dose: json['dose'],
        via: json['via'],
        hora: json['hora'] != null ? DateTime.parse(json['hora']) : null,
        tecnica: json['tecnica'],
      );
}
