class Medicacao {
  String nome;
  String? dose;
  String? via;
  double? volume; // volume em ml (opcional)
  DateTime? hora;
  String? tecnica; // NOVO CAMPO (opcional)

  Medicacao({
    required this.nome,
    this.dose,
    this.via,
    this.volume,
    this.hora,
    this.tecnica,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'dose': dose,
    'via': via,
    'volume': volume,
        'hora': hora?.toIso8601String(),
        'tecnica': tecnica,
      };

  factory Medicacao.fromJson(Map<String, dynamic> json) => Medicacao(
        nome: json['nome'] ?? '',
        dose: json['dose'],
        via: json['via'],
    volume: json['volume'] != null ? (json['volume'] is num ? (json['volume'] as num).toDouble() : double.tryParse(json['volume'].toString())) : null,
    hora: json['hora'] != null ? DateTime.parse(json['hora']) : null,
        tecnica: json['tecnica'],
      );
}
