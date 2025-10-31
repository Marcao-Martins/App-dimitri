/// Modelo para representar um cálculo de transfusão sanguínea
class TransfusionCalculation {
  final String species;
  final double weight;
  final int factor;
  final int desiredHematocrit;
  final int recipientHematocrit;
  final int bagHematocrit;
  final double volumeMl;

  TransfusionCalculation({
    required this.species,
    required this.weight,
    required this.factor,
    required this.desiredHematocrit,
    required this.recipientHematocrit,
    required this.bagHematocrit,
    required this.volumeMl,
  });

  /// Retorna os fatores disponíveis para cada espécie
  static List<int> getFactorsForSpecies(String species) {
    switch (species) {
      case 'Cão':
        return [80, 90];
      case 'Gato':
        return [40, 60];
      default:
        return [80];
    }
  }

  /// Retorna o fator padrão para cada espécie
  static int getDefaultFactor(String species) {
    switch (species) {
      case 'Cão':
        return 90;
      case 'Gato':
        return 60;
      default:
        return 90;
    }
  }

  /// Calcula o volume de sangue necessário
  /// Fórmula: Volume (mL) = (Peso × Fator × (Ht_desejado - Ht_receptor)) / Ht_bolsa
  static TransfusionCalculation calculate({
    required String species,
    required double weight,
    required int factor,
    required int desiredHematocrit,
    required int recipientHematocrit,
    required int bagHematocrit,
  }) {
    // Validação básica
    if (bagHematocrit == 0) {
      throw ArgumentError('Hematócrito da bolsa não pode ser zero');
    }

    // Cálculo do volume
    final volume = (weight * factor * (desiredHematocrit - recipientHematocrit)) / bagHematocrit;

    return TransfusionCalculation(
      species: species,
      weight: weight,
      factor: factor,
      desiredHematocrit: desiredHematocrit,
      recipientHematocrit: recipientHematocrit,
      bagHematocrit: bagHematocrit,
      volumeMl: volume,
    );
  }

  /// Retorna uma descrição do cálculo
  String getDescription() {
    return 'Transfusão para $species de $weight kg\n'
        'Ht desejado: $desiredHematocrit% | Ht receptor: $recipientHematocrit%\n'
        'Ht bolsa: $bagHematocrit% | Fator: $factor';
  }

  /// Retorna a taxa de infusão recomendada
  String getInfusionRateRecommendation() {
    if (species == 'Cão') {
      return 'Taxa recomendada: 10-20 mL/kg/h (primeira hora)\n'
          'Máximo: 22 mL/kg/h após primeira hora';
    } else {
      return 'Taxa recomendada: 5-10 mL/kg/h (primeira hora)\n'
          'Máximo: 11 mL/kg/h após primeira hora';
    }
  }
}
