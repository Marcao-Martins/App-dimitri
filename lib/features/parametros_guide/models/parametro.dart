class Parametro {
  final String nome;
  final String cao;
  final String gato;
  final String cavalo;
  final String comentarios;
  final String referencias;

  Parametro({
    required this.nome,
    required this.cao,
    required this.gato,
    required this.cavalo,
    required this.comentarios,
    required this.referencias,
  });

  factory Parametro.fromCsv(List<dynamic> row) {
    return Parametro(
      nome: row[0] as String,
      cao: row[1] as String,
      gato: row[2] as String,
      cavalo: row[3] as String,
      comentarios: row[4] as String,
      referencias: row[5] as String,
    );
  }
}
