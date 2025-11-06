

class VeterinaryParameter {
  final String species;
  final String parameterName;
  final String parameterValue;
  final String? comments;
  final List<String>? references;
  final String category;

  VeterinaryParameter({
    required this.species,
    required this.parameterName,
    required this.parameterValue,
    this.comments,
    this.references,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'species': species,
      'parameter_name': parameterName,
      'parameter_value': parameterValue,
      'comments': comments,
      'references': references,
      'category': category,
    };
  }

  static String getCategoryForParameter(String parameterName) {
    final cardiovascular = [
      'Frequência cardíaca (FC)',
      'Pressão arterial sistólica (PAS)',
      'Pressão arterial média (PAM)',
      'Pressão arterial diastólica (PAD)',
      'Pressão venosa central (PVC)',
      'Volume sistólico (VS)',
      'Índice cardíaco (IC)',
      'Índice de entrega de O2 (DO2)',
      'CaO2',
      'Equação de shunt (Qs/Qt)',
    ];
    final respiratory = [
      'Frequência respiratória (FR)',
      'Volume corrente (Vt)',
      'Saturação arterial de O2 (SpO2)',
      'CO2 expirado final (EtCO2)',
      'Pressão arterial de O2 (PaO2)',
      'Pressão arterial de CO2 (PaCO2)',
      'P(A-a)O2',
      'Razão PaO2:FiO2',
      'Razão SpO2/FiO2',
      'Complacência dinâmica (Cdyn)',
      'Resistência de vias aéreas (Raw)',
    ];
    final metabolic = [
      'Temperatura retal (TR)',
      'Débito urinário (DU)',
      'Glicemia',
      'pH arterial',
      'Bicarbonato arterial (HCO3-)',
      'Base excess (BE)',
      'Sódio (Na+)',
      'Potássio (K+)',
      'Cálcio ionizado (iCa)',
      'Cloreto (Cl-)',
      'Anion gap (AG)',
      'Lactato (Lac-)',
    ];
    final hematological = [
      'Hemácias',
      'Concentração de hemoglobina (Hb)',
      'Hematócrito (Ht) ou Volume globular (VG)',
      'Proteínas totais (PT), plasma',
      'Proteínas totais (PT), soro',
      'Albumina (Alb)',
    ];
    final echocardiographic = [
      'Parâmetros ecocardiográficos beira-de-leito',
      'Fração de encurtamento (SF)',
      'Fração de ejeção (EF)',
      'Razão átrio esquerdo-aorta (LA:Ao)',
      'Tempo de relaxamento isovolumétrico (TRIV)',
      'E/A',
      'Diâmetro diastólico final do ventrículo esquerdo (LVEDd)',
    ];
    final dynamicIndices = [
      'Índices dinâmicos',
      'Índice de colapsabilidade da veia cava caudal (CVC-CI)',
      'Variação da pressão de pulso (PPV)',
      'Índice de variabilidade pletismográfica (PVI)',
      'Variação da pressão sistólica (SPV)',
    ];

    if (cardiovascular.contains(parameterName)) return 'Cardiovascular';
    if (respiratory.contains(parameterName)) return 'Respiratório';
    if (metabolic.contains(parameterName)) return 'Metabólico';
    if (hematological.contains(parameterName)) return 'Hematológico';
    if (echocardiographic.contains(parameterName)) return 'Ecocardiográfico';
    if (dynamicIndices.contains(parameterName)) return 'Índices Dinâmicos';
    return 'Outros';
  }
}
