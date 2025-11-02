class FarmacoIntraoperatorio {
  String nome;
  double dose;
  String unidade;
  String via;
  DateTime hora;

  FarmacoIntraoperatorio({
    required this.nome,
    required this.dose,
    required this.unidade,
    required this.via,
    required this.hora,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'dose': dose,
        'unidade': unidade,
        'via': via,
        'hora': hora.toIso8601String(),
      };

  factory FarmacoIntraoperatorio.fromJson(Map<String, dynamic> json) =>
      FarmacoIntraoperatorio(
        nome: json['nome'] ?? '',
        dose: (json['dose'] as num?)?.toDouble() ?? 0.0,
        unidade: json['unidade'] ?? 'mg',
        via: json['via'] ?? '',
        hora: DateTime.parse(json['hora']),
      );
}
