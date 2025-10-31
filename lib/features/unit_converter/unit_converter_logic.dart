/// Lógica de conversão para o Conversor de Unidades.
class UnitConverter {
  // Fatores de conversão para a unidade base (g)
  static const Map<String, double> _massFactors = {
    'ng': 1e-9,
    'mcg (µg)': 1e-6,
    'mg': 1e-3,
    'g': 1.0,
    'kg': 1000.0,
    'lb': 453.59237,
  };

  // Fatores de conversão para a unidade base (L)
  static const Map<String, double> _volumeFactors = {
    'L': 1.0,
    'dL': 0.1,
    'mL': 1e-3,
    'µL': 1e-6,
  };

  // Fatores de conversão para a unidade base (Pa)
  static const Map<String, double> _pressureFactors = {
    'kPa': 1000.0,
    'Pa': 1.0,
    'bar': 100000.0,
    'atm': 101325.0,
    'mmHg': 133.322387415,
    'cmH₂O': 98.0665,
  };

  /// Converte um valor entre duas unidades.
  static double convert(double value, String fromUnit, String toUnit, Map<String, double> factors) {
    if (fromUnit == toUnit) return value;

    // Converte 'de' para a unidade base
    double baseValue = value * (factors[fromUnit] ?? 1.0);

    // Converte da unidade base para 'para'
    double finalValue = baseValue / (factors[toUnit] ?? 1.0);

    return finalValue;
  }

  /// Converte temperatura.
  static double convertTemperature(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    // Primeiro, converte para Celsius (nossa unidade base para temperatura)
    double celsiusValue;
    switch (fromUnit) {
      case '°F':
        celsiusValue = (value - 32) * 5 / 9;
        break;
      case 'K':
        celsiusValue = value - 273.15;
        break;
      case '°C':
      default:
        celsiusValue = value;
        break;
    }

    // Agora, converte de Celsius para a unidade de destino
    double result;
    switch (toUnit) {
      case '°F':
        result = (celsiusValue * 9 / 5) + 32;
        break;
      case 'K':
        result = celsiusValue + 273.15;
        break;
      case '°C':
      default:
        result = celsiusValue;
        break;
    }
    return result;
  }

  /// Retorna os fatores de conversão para uma dada categoria.
  static Map<String, double> getFactors(String category) {
    switch (category) {
      case 'mass':
        return _massFactors;
      case 'volume':
        return _volumeFactors;
      case 'pressure':
        return _pressureFactors;
      default:
        return {};
    }
  }
}
