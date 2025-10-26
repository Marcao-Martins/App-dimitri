import '../models/medication.dart';

/// Serviço de dados de medicamentos veterinários
/// Contém banco de dados local com medicamentos comuns em anestesia veterinária
class MedicationService {
  /// Lista de medicamentos pré-cadastrados
  static final List<Medication> _medications = [
    // ANESTÉSICOS INJETÁVEIS
    Medication(
      id: 'ketamine',
      name: 'Ketamina',
      minDose: 5.0,
      maxDose: 10.0,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Anestésico Dissociativo',
      indications: 'Indução anestésica, procedimentos curtos, analgesia',
      contraindications: 'Hipertensão, insuficiência cardíaca, gestação avançada',
      precautions: 'Pode causar salivação excessiva. Usar com anticolinérgico.',
      description: 'Anestésico dissociativo com propriedades analgésicas.',
    ),
    
    Medication(
      id: 'propofol',
      name: 'Propofol',
      minDose: 4.0,
      maxDose: 6.0,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Anestésico Intravenoso',
      indications: 'Indução e manutenção anestésica',
      contraindications: 'Hipovolemia, choque, hipotensão',
      precautions: 'Depressão respiratória. Monitorar pressão arterial.',
      description: 'Anestésico de ação rápida com recuperação suave.',
    ),
    
    Medication(
      id: 'tiletamine',
      name: 'Tiletamina + Zolazepam',
      minDose: 6.0,
      maxDose: 10.0,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Anestésico Dissociativo',
      indications: 'Anestesia geral, imobilização',
      contraindications: 'Doenças cardíacas graves, gestação',
      precautions: 'Recuperação prolongada em gatos.',
      description: 'Combinação de anestésico dissociativo e benzodiazepínico.',
    ),
    
    // SEDATIVOS E TRANQUILIZANTES
    Medication(
      id: 'acepromazine',
      name: 'Acepromazina',
      minDose: 0.01,
      maxDose: 0.05,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Tranquilizante Fenotiazínico',
      indications: 'Pré-medicação anestésica, sedação leve',
      contraindications: 'Choque, traumatismo craniano, epilepsia',
      precautions: 'Pode causar hipotensão. Evitar em animais debilitados.',
      description: 'Tranquilizante com efeito antiemético.',
    ),
    
    Medication(
      id: 'midazolam',
      name: 'Midazolam',
      minDose: 0.2,
      maxDose: 0.4,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Benzodiazepínico',
      indications: 'Sedação, relaxamento muscular, anticonvulsivante',
      contraindications: 'Glaucoma agudo, miastenia gravis',
      precautions: 'Reversível com flumazenil.',
      description: 'Sedativo com propriedades ansiolíticas e miorrelaxantes.',
    ),
    
    Medication(
      id: 'dexmedetomidine',
      name: 'Dexmedetomidina',
      minDose: 0.005,
      maxDose: 0.020,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Agonista α2-Adrenérgico',
      indications: 'Sedação, analgesia, pré-medicação',
      contraindications: 'Doença cardiovascular grave, diabetes',
      precautions: 'Pode causar bradicardia e hipertensão inicial. Reversível com atipamezole.',
      description: 'Sedativo-analgésico potente com ação central.',
    ),
    
    Medication(
      id: 'xylazine',
      name: 'Xilazina',
      minDose: 0.5,
      maxDose: 1.0,
      unit: 'mg/kg',
      species: ['Canino', 'Equino', 'Bovino'],
      category: 'Agonista α2-Adrenérgico',
      indications: 'Sedação, relaxamento muscular, analgesia',
      contraindications: 'Último trimestre de gestação, diabetes',
      precautions: 'Evitar em felinos (alta sensibilidade). Causa vômito em cães.',
      description: 'Sedativo-analgésico com propriedades miorrelaxantes.',
    ),
    
    // ANALGÉSICOS OPIOIDES
    Medication(
      id: 'morphine',
      name: 'Morfina',
      minDose: 0.2,
      maxDose: 0.5,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Opioide',
      indications: 'Dor moderada a grave',
      contraindications: 'Insuficiência respiratória grave',
      precautions: 'Pode causar vômito e bradicardia. Controlado pela ANVISA.',
      description: 'Analgésico opioide potente, padrão ouro para dor grave.',
    ),
    
    Medication(
      id: 'fentanyl',
      name: 'Fentanil',
      minDose: 0.002,
      maxDose: 0.010,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Opioide',
      indications: 'Analgesia transoperatória, dor grave',
      contraindications: 'Depressão respiratória grave',
      precautions: 'Ação rápida e curta. Pode causar rigidez muscular.',
      description: 'Opioide sintético de alta potência.',
    ),
    
    Medication(
      id: 'tramadol',
      name: 'Tramadol',
      minDose: 2.0,
      maxDose: 4.0,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Opioide Fraco',
      indications: 'Dor leve a moderada',
      contraindications: 'Uso concomitante com IMAO',
      precautions: 'Menor eficácia em gatos.',
      description: 'Analgésico opioide para dor leve a moderada.',
    ),
    
    Medication(
      id: 'methadone',
      name: 'Metadona',
      minDose: 0.2,
      maxDose: 0.5,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Opioide',
      indications: 'Pré-medicação, analgesia perioperatória',
      contraindications: 'Insuficiência respiratória',
      precautions: 'Ação prolongada. Boa escolha para analgesia pós-operatória.',
      description: 'Opioide sintético com longa duração.',
    ),
    
    // ANESTÉSICOS LOCAIS
    Medication(
      id: 'lidocaine',
      name: 'Lidocaína',
      minDose: 2.0,
      maxDose: 4.0,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Anestésico Local',
      indications: 'Bloqueios nervosos, anestesia local',
      contraindications: 'Bloqueio cardíaco, hipersensibilidade',
      precautions: 'Tóxico em gatos em doses altas. Não usar em infusão contínua em felinos.',
      description: 'Anestésico local de ação rápida.',
    ),
    
    Medication(
      id: 'bupivacaine',
      name: 'Bupivacaína',
      minDose: 1.0,
      maxDose: 2.0,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Anestésico Local',
      indications: 'Bloqueios nervosos prolongados',
      contraindications: 'Administração intravenosa',
      precautions: 'Cardiotóxico em doses elevadas. Ação prolongada.',
      description: 'Anestésico local de longa duração.',
    ),
    
    // ANTICOLINÉRGICOS
    Medication(
      id: 'atropine',
      name: 'Atropina',
      minDose: 0.02,
      maxDose: 0.04,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Anticolinérgico',
      indications: 'Bradicardia, redução de secreções',
      contraindications: 'Taquicardia, glaucoma',
      precautions: 'Pode causar taquicardia e midríase.',
      description: 'Anticolinérgico para controle de bradicardia.',
    ),
    
    // ANESTÉSICOS INALATÓRIOS (doses em MAC - Concentração Alveolar Mínima)
    Medication(
      id: 'isoflurane',
      name: 'Isoflurano',
      minDose: 1.3,
      maxDose: 1.6,
      unit: 'MAC%',
      species: ['Canino', 'Felino', 'Equino'],
      category: 'Anestésico Inalatório',
      indications: 'Manutenção anestésica',
      contraindications: 'Hipertermia maligna',
      precautions: 'Depressor cardiovascular dose-dependente.',
      description: 'Anestésico inalatório padrão para manutenção.',
    ),
    
    Medication(
      id: 'sevoflurane',
      name: 'Sevoflurano',
      minDose: 2.3,
      maxDose: 2.6,
      unit: 'MAC%',
      species: ['Canino', 'Felino', 'Equino'],
      category: 'Anestésico Inalatório',
      indications: 'Indução e manutenção anestésica',
      contraindications: 'Hipertermia maligna',
      precautions: 'Menos irritante que isoflurano. Indução mais rápida.',
      description: 'Anestésico inalatório de nova geração.',
    ),
    
    // OUTROS
    Medication(
      id: 'maropitant',
      name: 'Maropitanto',
      minDose: 1.0,
      maxDose: 1.0,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'Antiemético',
      indications: 'Prevenção de náusea e vômito perioperatório',
      contraindications: 'Animais com menos de 8 semanas',
      precautions: 'Aplicar SC ou IV lento.',
      description: 'Antiemético potente e seguro.',
    ),
    
    Medication(
      id: 'meloxicam',
      name: 'Meloxicam',
      minDose: 0.1,
      maxDose: 0.2,
      unit: 'mg/kg',
      species: ['Canino', 'Felino'],
      category: 'AINE',
      indications: 'Analgesia pós-operatória, anti-inflamatório',
      contraindications: 'Insuficiência renal, úlcera gástrica, desidratação',
      precautions: 'Administrar após fluidoterapia adequada.',
      description: 'Anti-inflamatório não esteroidal com ação analgésica.',
    ),
  ];
  
  /// Retorna todos os medicamentos
  static List<Medication> getAllMedications() {
    return List.unmodifiable(_medications);
  }
  
  /// Busca medicamentos por nome
  static List<Medication> searchByName(String query) {
    if (query.isEmpty) return getAllMedications();
    
    final lowerQuery = query.toLowerCase();
    return _medications
        .where((med) => med.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  /// Filtra medicamentos por espécie
  static List<Medication> filterBySpecies(String species) {
    return _medications
        .where((med) => med.isCompatibleWithSpecies(species))
        .toList();
  }
  
  /// Filtra medicamentos por categoria
  static List<Medication> filterByCategory(String category) {
    return _medications
        .where((med) => med.category == category)
        .toList();
  }
  
  /// Busca medicamento por ID
  static Medication? getMedicationById(String id) {
    try {
      return _medications.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Retorna todas as categorias disponíveis
  static List<String> getAllCategories() {
    return _medications
        .map((med) => med.category)
        .toSet()
        .toList()
      ..sort();
  }
  
  /// Retorna todas as espécies suportadas
  static List<String> getAllSpecies() {
    final allSpecies = <String>{};
    for (var med in _medications) {
      allSpecies.addAll(med.species);
    }
    return allSpecies.toList()..sort();
  }
}
