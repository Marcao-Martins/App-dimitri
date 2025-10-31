// lib/models/farmaco.dart
// Modelo de dados para fármacos veterinários
// Mapeia as colunas do CSV farmacos_veterinarios.csv

class Farmaco {
  final String postId;
  final String titulo;
  final String farmaco;
  final String classeFarmacologica;
  final String nomeComercial;
  final String mecanismoDeAcao;
  final String posologiaCaes;
  final String posologiaGatos;
  final String ivc;
  final String comentarios;
  final String referencia;
  final String postDate;
  final String link;

  Farmaco({
    required this.postId,
    required this.titulo,
    required this.farmaco,
    required this.classeFarmacologica,
    required this.nomeComercial,
    required this.mecanismoDeAcao,
    required this.posologiaCaes,
    required this.posologiaGatos,
    required this.ivc,
    required this.comentarios,
    required this.referencia,
    required this.postDate,
    required this.link,
  });

  /// Cria uma instância de Farmaco a partir de um Map (linha do CSV)
  factory Farmaco.fromJson(Map<String, dynamic> json) {
    return Farmaco(
      postId: json['post_id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      farmaco: json['farmaco']?.toString() ?? '',
      classeFarmacologica: json['classe_farmacologica']?.toString() ?? '',
      nomeComercial: json['nome_comercial']?.toString() ?? '',
      mecanismoDeAcao: json['mecanismo_de_acao']?.toString() ?? '',
      posologiaCaes: json['posologia_caes']?.toString() ?? '',
      posologiaGatos: json['posologia_gatos']?.toString() ?? '',
      ivc: json['ivc']?.toString() ?? '',
      comentarios: json['comentarios']?.toString() ?? '',
      referencia: json['referencia']?.toString() ?? '',
      postDate: json['post_date']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }

  /// Converte a instância de Farmaco para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'titulo': titulo,
      'farmaco': farmaco,
      'classe_farmacologica': classeFarmacologica,
      'nome_comercial': nomeComercial,
      'mecanismo_de_acao': mecanismoDeAcao,
      'posologia_caes': posologiaCaes,
      'posologia_gatos': posologiaGatos,
      'ivc': ivc,
      'comentarios': comentarios,
      'referencia': referencia,
      'post_date': postDate,
      'link': link,
    };
  }

  /// Cria uma cópia da instância com campos atualizados
  Farmaco copyWith({
    String? postId,
    String? titulo,
    String? farmaco,
    String? classeFarmacologica,
    String? nomeComercial,
    String? mecanismoDeAcao,
    String? posologiaCaes,
    String? posologiaGatos,
    String? ivc,
    String? comentarios,
    String? referencia,
    String? postDate,
    String? link,
  }) {
    return Farmaco(
      postId: postId ?? this.postId,
      titulo: titulo ?? this.titulo,
      farmaco: farmaco ?? this.farmaco,
      classeFarmacologica: classeFarmacologica ?? this.classeFarmacologica,
      nomeComercial: nomeComercial ?? this.nomeComercial,
      mecanismoDeAcao: mecanismoDeAcao ?? this.mecanismoDeAcao,
      posologiaCaes: posologiaCaes ?? this.posologiaCaes,
      posologiaGatos: posologiaGatos ?? this.posologiaGatos,
      ivc: ivc ?? this.ivc,
      comentarios: comentarios ?? this.comentarios,
      referencia: referencia ?? this.referencia,
      postDate: postDate ?? this.postDate,
      link: link ?? this.link,
    );
  }
}
