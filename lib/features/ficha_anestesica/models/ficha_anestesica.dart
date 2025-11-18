import 'paciente.dart';
import 'medicacao.dart';
import 'parametro_monitorizacao.dart';
import 'intercorrencia.dart';
import 'farmaco_intraoperatorio.dart';

class FichaAnestesica {
  Paciente paciente;
  List<Medicacao> preAnestesica;
  List<Medicacao> antimicrobianos;
  List<Medicacao> inducao;
  List<Medicacao> manutencao;
  List<Medicacao> locorregional;
  List<ParametroMonitorizacao> parametros;
  List<Intercorrencia> intercorrencias;
  List<FarmacoIntraoperatorio> farmacosIntraoperatorios;
  List<Medicacao> analgesiaPosOperatoria;
  
  /// Imagens anexadas à ficha (caminhos dos arquivos)
  List<String> imagePaths;
  
  /// Tempo decorrido do procedimento em segundos
  int procedureTimeSeconds;
  
  /// Se o cronômetro estava rodando quando a ficha foi salva
  bool timerWasRunning;
  // Manejo de vias aéreas
  String? airwayIntubation;
  String? airwayTubeSize;
  String? airwayPreOxygenation;
  String? airwayPeriglotticAnesthesia;
  String? airwayLaryngealMask;
  String? airwayObservations;

  FichaAnestesica({
    required this.paciente,
    List<Medicacao>? preAnestesica,
    List<Medicacao>? antimicrobianos,
    List<Medicacao>? inducao,
    List<Medicacao>? manutencao,
    List<Medicacao>? locorregional,
    List<ParametroMonitorizacao>? parametros,
    List<Intercorrencia>? intercorrencias,
    List<FarmacoIntraoperatorio>? farmacosIntraoperatorios,
    List<Medicacao>? analgesiaPosOperatoria,
    List<String>? imagePaths,
    this.procedureTimeSeconds = 0,
    this.timerWasRunning = false,
    this.airwayIntubation,
    this.airwayTubeSize,
    this.airwayPreOxygenation,
    this.airwayPeriglotticAnesthesia,
    this.airwayLaryngealMask,
    this.airwayObservations,
  })  : preAnestesica = preAnestesica ?? [],
        antimicrobianos = antimicrobianos ?? [],
        inducao = inducao ?? [],
        manutencao = manutencao ?? [],
        locorregional = locorregional ?? [],
        parametros = parametros ?? [],
        intercorrencias = intercorrencias ?? [],
        farmacosIntraoperatorios = farmacosIntraoperatorios ?? [],
        analgesiaPosOperatoria = analgesiaPosOperatoria ?? [],
        imagePaths = imagePaths ?? [];

  Map<String, dynamic> toJson() => {
        'paciente': paciente.toJson(),
        'preAnestesica': preAnestesica.map((e) => e.toJson()).toList(),
        'antimicrobianos': antimicrobianos.map((e) => e.toJson()).toList(),
        'inducao': inducao.map((e) => e.toJson()).toList(),
        'manutencao': manutencao.map((e) => e.toJson()).toList(),
        'locorregional': locorregional.map((e) => e.toJson()).toList(),
        'parametros': parametros.map((e) => e.toJson()).toList(),
        'intercorrencias': intercorrencias.map((e) => e.toJson()).toList(),
        'farmacosIntraoperatorios': farmacosIntraoperatorios.map((e) => e.toJson()).toList(),
        'analgesiaPosOperatoria': analgesiaPosOperatoria.map((e) => e.toJson()).toList(),
        'imagePaths': imagePaths,
        'procedureTimeSeconds': procedureTimeSeconds,
        'timerWasRunning': timerWasRunning,
        'airwayIntubation': airwayIntubation,
        'airwayTubeSize': airwayTubeSize,
        'airwayPreOxygenation': airwayPreOxygenation,
        'airwayPeriglotticAnesthesia': airwayPeriglotticAnesthesia,
        'airwayLaryngealMask': airwayLaryngealMask,
        'airwayObservations': airwayObservations,
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
        farmacosIntraoperatorios: (json['farmacosIntraoperatorios'] as List?)?.map((e) => FarmacoIntraoperatorio.fromJson(e as Map<String, dynamic>)).toList(),
        analgesiaPosOperatoria: (json['analgesiaPosOperatoria'] as List?)?.map((e) => Medicacao.fromJson(e as Map<String, dynamic>)).toList(),
        imagePaths: (json['imagePaths'] as List?)?.map((e) => e as String).toList() ?? [],
        procedureTimeSeconds: json['procedureTimeSeconds'] as int? ?? 0,
        timerWasRunning: json['timerWasRunning'] as bool? ?? false,
        airwayIntubation: json['airwayIntubation'] as String?,
        airwayTubeSize: json['airwayTubeSize'] as String?,
        airwayPreOxygenation: json['airwayPreOxygenation'] as String?,
        airwayPeriglotticAnesthesia: json['airwayPeriglotticAnesthesia'] as String?,
        airwayLaryngealMask: json['airwayLaryngealMask'] as String?,
        airwayObservations: json['airwayObservations'] as String?,
      );
}
