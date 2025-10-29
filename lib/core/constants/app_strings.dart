/// Strings e constantes de texto do aplicativo
/// Preparado para internacionalização futura (i18n)
class AppStrings {
  // App Info
  static const String appName = 'GDAV';
  static const String appSubtitle = 'Grupo de Desenvolvimento em Anestesiologia Veterinária';
  static const String appVersion = '1.0.0';
  
  // Navegação
  static const String navCalculator = 'Calculadora';
  static const String navChecklist = 'Checklist';
  static const String navDrugGuide = 'Guia de Fármacos';
  
  // Calculadora de Doses
  static const String calculatorTitle = 'Calculadora de Doses';
  static const String weightLabel = 'Peso do Animal (kg)';
  static const String speciesLabel = 'Espécie';
  static const String medicationLabel = 'Medicamento';
  static const String calculateButton = 'Calcular Dose';
  static const String doseResult = 'Dose Recomendada';
  static const String doseRange = 'Faixa Segura';
  static const String history = 'Histórico';
  
  // Espécies
  static const String canine = 'Canino';
  static const String feline = 'Felino';
  static const String equine = 'Equino';
  static const String bovine = 'Bovino';
  
  // Checklist Pré-Operatório
  static const String checklistTitle = 'Checklist Pré-Operatório';
  static const String asaClassification = 'Classificação ASA';
  static const String fastingTimer = 'Timer de Jejum';
  static const String exportPdf = 'Exportar PDF';
  static const String resetChecklist = 'Resetar Checklist';
  
  // Guia de Fármacos
  static const String drugGuideTitle = 'Guia de Fármacos';
  static const String searchDrug = 'Buscar medicamento...';
  static const String indications = 'Indicações';
  static const String contraindications = 'Contraindicações';
  static const String dosage = 'Dosagem';
  static const String precautions = 'Precauções';
  
  // Mensagens de Validação
  static const String errorEmptyWeight = 'Por favor, insira o peso do animal';
  static const String errorInvalidWeight = 'Peso inválido';
  static const String errorSelectSpecies = 'Selecione uma espécie';
  static const String errorSelectMedication = 'Selecione um medicamento';
  static const String warningHighDose = 'ATENÇÃO: Dose acima do recomendado';
  static const String warningLowDose = 'ATENÇÃO: Dose abaixo do recomendado';
  
  // Mensagens de Confirmação
  static const String confirmCalculation = 'Confirmar cálculo?';
  static const String confirmReset = 'Deseja resetar o checklist?';
  static const String saveSuccess = 'Salvo com sucesso';
  static const String exportSuccess = 'Exportado com sucesso';
  
  // Botões Gerais
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String save = 'Salvar';
  static const String clear = 'Limpar';
  static const String close = 'Fechar';
}
