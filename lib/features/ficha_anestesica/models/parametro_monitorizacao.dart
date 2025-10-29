class ParametroMonitorizacao {
  DateTime momento;
  int? fc;
  int? fr;
  int? spo2;
  int? etco2;
  int? pas;
  int? pad;
  int? pam;
  double? temp;

  ParametroMonitorizacao({
    required this.momento,
    this.fc,
    this.fr,
    this.spo2,
    this.etco2,
    this.pas,
    this.pad,
    this.pam,
    this.temp,
  });

  Map<String, dynamic> toJson() => {
        'momento': momento.toIso8601String(),
        'fc': fc,
        'fr': fr,
        'spo2': spo2,
        'etco2': etco2,
        'pas': pas,
        'pad': pad,
        'pam': pam,
        'temp': temp,
      };

  factory ParametroMonitorizacao.fromJson(Map<String, dynamic> json) => ParametroMonitorizacao(
        momento: DateTime.parse(json['momento']),
        fc: json['fc'],
        fr: json['fr'],
        spo2: json['spo2'],
        etco2: json['etco2'],
        pas: json['pas'],
        pad: json['pad'],
        pam: json['pam'],
        temp: (json['temp'] is num) ? (json['temp'] as num).toDouble() : null,
      );
}
