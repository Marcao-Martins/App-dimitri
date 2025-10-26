/// Classe utilitária para formatação de valores
class FormatUtils {
  /// Formata um valor double para exibição
  /// Exemplo: 15.5 -> "15.5" / 15.0 -> "15"
  static String formatDouble(double value, {int decimals = 1}) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(decimals);
  }
  
  /// Formata peso com unidade
  /// Exemplo: 15.5 -> "15.5 kg"
  static String formatWeight(double weightKg) {
    return '${formatDouble(weightKg)} kg';
  }
  
  /// Formata dose com unidade
  /// Exemplo: 0.5, "mg/kg" -> "0.5 mg/kg"
  static String formatDose(double dose, String unit) {
    return '${formatDouble(dose, decimals: 2)} $unit';
  }
  
  /// Formata duração em horas e minutos
  /// Exemplo: Duration(hours: 8, minutes: 30) -> "8h 30min"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
  
  /// Formata data e hora
  /// Exemplo: DateTime(2024, 10, 26, 14, 30) -> "26/10/2024 14:30"
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Formata apenas data
  /// Exemplo: DateTime(2024, 10, 26) -> "26/10/2024"
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year}';
  }
  
  /// Formata apenas hora
  /// Exemplo: DateTime(2024, 10, 26, 14, 30) -> "14:30"
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Formata porcentagem
  /// Exemplo: 0.75 -> "75%"
  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }
}
