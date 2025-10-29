import 'paciente.dart';
import 'medicacao.dart';
import 'parametro_monitorizacao.dart';
import 'intercorrencia.dart';

class FichaAnestesica {
  Paciente paciente;
  List<Medicacao> preAnestesica;
  List<Medicacao> antimicrobianos;
  List<Medicacao> inducao;
  List<Medicacao> manutencao;
  List<Medicacao> locorregional;
  List<ParametroMonitorizacao> parametros;
  List<Intercorrencia> intercorrencias;
  List<Medicacao> analgesiaPosOperatoria;

  FichaAnestesica({
    required this.paciente,
    List<Medicacao>? preAnestesica,
    List<Medicacao>? antimicrobianos,
    List<Medicacao>? inducao,
    List<Medicacao>? manutencao,
    List<Medicacao>? locorregional,
    List<ParametroMonitorizacao>? parametros,
    List<Intercorrencia>? intercorrencias,
    List<Medicacao>? analgesiaPosOperatoria,
  })  : preAnestesica = preAnestesica ?? [],
        antimicrobianos = antimicrobianos ?? [],
        inducao = inducao ?? [],
        manutencao = manutencao ?? [],
        locorregional = locorregional ?? [],
        parametros = parametros ?? [],
        intercorrencias = intercorrencias ?? [],
        analgesiaPosOperatoria = analgesiaPosOperatoria ?? [];

  Map<String, dynamic> toJson() => {
        'paciente': paciente.toJson(),
        'preAnestesica': preAnestesica.map((e) => e.toJson()).toList(),
        'antimicrobianos': antimicrobianos.map((e) => e.toJson()).toList(),
        'inducao': inducao.map((e) => e.toJson()).toList(),
        'manutencao': manutencao.map((e) => e.toJson()).toList(),
        'locorregional': locorregional.map((e) => e.toJson()).toList(),
        'parametros': parametros.map((e) => e.toJson()).toList(),
        'intercorrencias': intercorrencias.map((e) => e.toJson()).toList(),
        'analgesiaPosOperatoria': analgesiaPosOperatoria.map((e) => e.toJson()).toList(),
      };

  factory FichaAnestesica.fromJson(Map<String, dynamic> json) => FichaAnestesica(
        paciente: Paciente.fromJson(json['paciente'] as Map<String, dynamic>),
        preAnestesica: (json['preAnestesica'] as List?)?.map((e) => Medicacao.fromJson(e as Map<String, dynamic>)).toList(),
        antimicrobianos: (json['antimicrobianos'] as List?)?.map((e) => Medicacao.fromJson(e as Map<String, dynamic>)).toList(),
        inducao: (json['inducao'] as List?)?.map((e) => Medicacao.fromJson(e as Map<String, dynamic>)).toList(),
        manutencao: (json['manutencao'] as List?)?.map((e) => Medicacao.fromJson(e as Map<String, dynamic>)).toList(),
        locorregional: (json['locorregional'] as List?)?.map((e) => Medicacao.fromJson(e as Map<String, dynamic>)).toList(),
        parametros: (json['parametros'] as List?)?.map((e) => ParametroMonitorizacao.fromJson(e as Map<String, dynamic>)).toList(),
        intercorrencias: (json['intercorrencias'] as List?)?.map((e) => Intercorrencia.fromJson(e as Map<String, dynamic>)).toList(),
        analgesiaPosOperatoria: (json['analgesiaPosOperatoria'] as List?)?.map((e) => Medicacao.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
