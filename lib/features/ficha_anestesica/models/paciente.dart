class Paciente {
  String nome;
  DateTime? data;
  String? especie;
  String? sexo;
  double? peso;
  String? idade;
  String? asa;
  String? procedimento;
  String? doencas;
  String? observacoes;

  Paciente({
    required this.nome,
    this.data,
    this.especie,
    this.sexo,
    this.peso,
    this.idade,
    this.asa,
    this.procedimento,
    this.doencas,
    this.observacoes,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'data': data?.toIso8601String(),
        'especie': especie,
        'sexo': sexo,
        'peso': peso,
        'idade': idade,
        'asa': asa,
        'procedimento': procedimento,
        'doencas': doencas,
        'observacoes': observacoes,
      };

  factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
        nome: json['nome'] ?? '',
        data: json['data'] != null ? DateTime.parse(json['data']) : null,
        especie: json['especie'],
        sexo: json['sexo'],
        peso: (json['peso'] is num) ? (json['peso'] as num).toDouble() : null,
        idade: json['idade'],
        asa: json['asa'],
        procedimento: json['procedimento'],
        doencas: json['doencas'],
        observacoes: json['observacoes'],
      );
}
