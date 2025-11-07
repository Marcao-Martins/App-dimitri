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
    String clean(dynamic v) {
      var s = (v ?? '').toString();
      // Normaliza quebras de linha para espaço simples
      s = s.replaceAll('\r\n', ' ').replaceAll('\n', ' ').replaceAll('\r', ' ');
      s = s.trim();
      // Remove aspas de borda (simples e duplas, incluindo aspas tipográficas)
      if (s.isNotEmpty && (s.startsWith('"') || s.startsWith("'") || s.startsWith('“') || s.startsWith('‘'))) {
        s = s.substring(1);
      }
      if (s.isNotEmpty && (s.endsWith('"') || s.endsWith("'") || s.endsWith('”') || s.endsWith('’'))) {
        s = s.substring(0, s.length - 1);
      }
      // Desescapa aspas duplas dobradas
      s = s.replaceAll('""', '"');
      // Colapsa múltiplos espaços
      s = s.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
      return s;
    }

    return Parametro(
      nome: clean(row[0]),
      cao: clean(row[1]),
      gato: clean(row[2]),
      cavalo: clean(row[3]),
      comentarios: clean(row[4]),
      referencias: clean(row[5]),
    );
  }
}
