/// Classe utilitária para validação de entradas
class ValidationUtils {
  /// Valida peso do animal
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o peso do animal';
    }
    
    final weight = double.tryParse(value.replaceAll(',', '.'));
    
    if (weight == null) {
      return 'Peso inválido';
    }
    
    if (weight <= 0) {
      return 'Peso deve ser maior que zero';
    }
    
    if (weight > 1000) {
      return 'Peso muito alto. Verifique a unidade (kg)';
    }
    
    return null;
  }
  
  /// Valida dose calculada
  static String? validateDose(double dose, double minDose, double maxDose) {
    if (dose < minDose * 0.8) {
      return 'ATENÇÃO: Dose abaixo do recomendado';
    }
    
    if (dose > maxDose * 1.2) {
      return 'ATENÇÃO: Dose acima do recomendado';
    }
    
    return null;
  }
  
  /// Valida nome (não pode ser vazio)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira um nome';
    }
    
    if (value.trim().length < 2) {
      return 'Nome muito curto';
    }
    
    return null;
  }
  
  /// Valida idade
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Idade é opcional
    }
    
    final age = int.tryParse(value);
    
    if (age == null) {
      return 'Idade inválida';
    }
    
    if (age < 0) {
      return 'Idade não pode ser negativa';
    }
    
    if (age > 50) {
      return 'Idade muito alta. Verifique o valor';
    }
    
    return null;
  }
  
  /// Valida campo obrigatório genérico
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, preencha o campo $fieldName';
    }
    return null;
  }
  
  /// Valida seleção de dropdown
  static String? validateSelection(dynamic value, String fieldName) {
    if (value == null) {
      return 'Por favor, selecione $fieldName';
    }
    return null;
  }
}
