import '../models/checklist.dart';

/// Serviço de dados do Checklist Pré-Operatório
/// Fornece template padrão baseado em protocolos veterinários
class ChecklistService {
  /// Retorna o template padrão do checklist pré-operatório
  static List<ChecklistItem> getDefaultChecklistItems() {
    return [
      // CATEGORIA: PACIENTE
      ChecklistItem(
        id: 'patient_01',
        title: 'Identificação do Paciente',
        description: 'Verificar nome, espécie, peso e idade corretos',
        category: 'Paciente',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'patient_02',
        title: 'Jejum Adequado',
        description: 'Confirmar jejum alimentar conforme protocolo',
        category: 'Paciente',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'patient_03',
        title: 'Exame Físico',
        description: 'Realizar exame físico completo: FC, FR, TR, TPC, mucosas',
        category: 'Paciente',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'patient_04',
        title: 'Classificação ASA',
        description: 'Determinar classificação de risco anestésico (ASA I-V)',
        category: 'Paciente',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'patient_05',
        title: 'Histórico Médico',
        description: 'Revisar histórico de doenças, cirurgias e reações prévias',
        category: 'Paciente',
        isCritical: false,
      ),
      
      ChecklistItem(
        id: 'patient_06',
        title: 'Alergias e Medicações',
        description: 'Verificar alergias conhecidas e medicações em uso',
        category: 'Paciente',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'patient_07',
        title: 'Exames Complementares',
        description: 'Revisar exames laboratoriais e de imagem disponíveis',
        category: 'Paciente',
        isCritical: false,
      ),
      
      // CATEGORIA: EQUIPAMENTO
      ChecklistItem(
        id: 'equipment_01',
        title: 'Máquina de Anestesia',
        description: 'Testar vazamentos e funcionamento do sistema de anestesia',
        category: 'Equipamento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'equipment_02',
        title: 'Oxigênio',
        description: 'Verificar nível adequado de oxigênio no cilindro',
        category: 'Equipamento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'equipment_03',
        title: 'Circuito Anestésico',
        description: 'Verificar integridade do circuito e cal sodada',
        category: 'Equipamento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'equipment_04',
        title: 'Tubos Endotraqueais',
        description: 'Preparar tubos de tamanhos adequados e testar cuffs',
        category: 'Equipamento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'equipment_05',
        title: 'Laringoscópio',
        description: 'Verificar funcionamento da lâmina e bateria',
        category: 'Equipamento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'equipment_06',
        title: 'Monitorização',
        description: 'Testar monitor cardíaco, oxímetro e capnógrafo',
        category: 'Equipamento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'equipment_07',
        title: 'Aspirador',
        description: 'Verificar funcionamento do sistema de aspiração',
        category: 'Equipamento',
        isCritical: false,
      ),
      
      ChecklistItem(
        id: 'equipment_08',
        title: 'Carro de Emergência',
        description: 'Confirmar disponibilidade e validade de medicações de emergência',
        category: 'Equipamento',
        isCritical: true,
      ),
      
      // CATEGORIA: MEDICAÇÃO
      ChecklistItem(
        id: 'medication_01',
        title: 'Cálculo de Doses',
        description: 'Calcular e preparar doses de pré-medicação',
        category: 'Medicação',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'medication_02',
        title: 'Anestésico Inalatório',
        description: 'Verificar nível adequado de anestésico no vaporizador',
        category: 'Medicação',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'medication_03',
        title: 'Fluidoterapia',
        description: 'Preparar fluidos e calcular taxa de infusão',
        category: 'Medicação',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'medication_04',
        title: 'Analgesia',
        description: 'Preparar protocolo analgésico multimodal',
        category: 'Medicação',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'medication_05',
        title: 'Medicações de Emergência',
        description: 'Calcular doses de atropina, efedrina e adrenalina',
        category: 'Medicação',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'medication_06',
        title: 'Antiemético',
        description: 'Preparar antiemético profilático se indicado',
        category: 'Medicação',
        isCritical: false,
      ),
      
      // CATEGORIA: PROCEDIMENTO
      ChecklistItem(
        id: 'procedure_01',
        title: 'Termo de Consentimento',
        description: 'Confirmar assinatura do termo pelo responsável',
        category: 'Procedimento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'procedure_02',
        title: 'Acesso Venoso',
        description: 'Estabelecer acesso venoso adequado',
        category: 'Procedimento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'procedure_03',
        title: 'Posicionamento',
        description: 'Preparar mesa cirúrgica e posicionamento adequado',
        category: 'Procedimento',
        isCritical: false,
      ),
      
      ChecklistItem(
        id: 'procedure_04',
        title: 'Tricotomia e Antissepsia',
        description: 'Realizar tricotomia e antissepsia do sítio cirúrgico',
        category: 'Procedimento',
        isCritical: false,
      ),
      
      ChecklistItem(
        id: 'procedure_05',
        title: 'Monitorização Conectada',
        description: 'Conectar todos os monitores e verificar leituras',
        category: 'Procedimento',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'procedure_06',
        title: 'Time-Out Cirúrgico',
        description: 'Realizar time-out com equipe: paciente, procedimento, lateralidade',
        category: 'Procedimento',
        isCritical: true,
      ),
      
      // CATEGORIA: SEGURANÇA
      ChecklistItem(
        id: 'safety_01',
        title: 'Ambú',
        description: 'Verificar disponibilidade de sistema de ventilação manual',
        category: 'Segurança',
        isCritical: true,
      ),
      
      ChecklistItem(
        id: 'safety_02',
        title: 'Reversão Anestésica',
        description: 'Preparar antagonistas se necessário (atipamezole, flumazenil)',
        category: 'Segurança',
        isCritical: false,
      ),
      
      ChecklistItem(
        id: 'safety_03',
        title: 'Aquecimento',
        description: 'Preparar sistema de aquecimento (manta térmica, bolsas)',
        category: 'Segurança',
        isCritical: false,
      ),
      
      ChecklistItem(
        id: 'safety_04',
        title: 'Contato de Emergência',
        description: 'Confirmar dados de contato do responsável',
        category: 'Segurança',
        isCritical: true,
      ),
    ];
  }
  
  /// Retorna todas as categorias do checklist
  static List<String> getCategories() {
    return [
      'Paciente',
      'Equipamento',
      'Medicação',
      'Procedimento',
      'Segurança',
    ];
  }
  
  /// Agrupa itens por categoria
  static Map<String, List<ChecklistItem>> groupItemsByCategory(
    List<ChecklistItem> items,
  ) {
    final grouped = <String, List<ChecklistItem>>{};
    
    for (var item in items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    
    return grouped;
  }
  
  /// Retorna apenas itens críticos
  static List<ChecklistItem> getCriticalItems(List<ChecklistItem> items) {
    return items.where((item) => item.isCritical).toList();
  }
}
