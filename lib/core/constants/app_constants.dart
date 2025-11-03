/// Constantes numéricas e configurações do aplicativo
class AppConstants {
  // Configurações de Layout
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Configurações de Texto
  static const double headingFontSize = 24.0;
  static const double subheadingFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  
  // Limites de Dose (multiplicadores de segurança)
  static const double safeDoseMultiplierMin = 0.8;
  static const double safeDoseMultiplierMax = 1.2;
  
  // Configurações de Persistência
  static const String historyBoxName = 'calculation_history';
  static const String checklistBoxName = 'checklist_data';
  static const String settingsBoxName = 'app_settings';
  static const int maxHistoryItems = 50;
  
  // Classificação ASA (American Society of Anesthesiologists)
  static const List<String> asaClassifications = [
    'ASA I - Paciente normal e saudável',
    'ASA II - Doença sistêmica leve',
    'ASA III - Doença sistêmica grave',
    'ASA IV - Doença sistêmica grave com risco de vida',
    'ASA V - Moribundo sem expectativa de sobrevivência',
  ];
  
  // Tempos de Jejum Recomendados (em horas)
  static const Map<String, int> fastingTimes = {
    'Canino': 8,
    'Felino': 6,
    'Equino': 12,
    'Bovino': 12,
  };
  
  // Animações
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
