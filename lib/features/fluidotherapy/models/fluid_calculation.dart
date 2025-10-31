/// Modelo para representar um cálculo de fluidoterapia
class FluidCalculation {
  final String species;
  final double weight;
  final bool hasDehydration;
  final int? rehydrationTime;
  final double? dehydrationPercent;
  final double maintenanceVolume;
  final double? rehydrationVolume;
  final double totalDailyVolume;
  final double infusionRateMlPerHour;
  final double dropsPerMinute;
  final double secondsBetweenDrops;

  FluidCalculation({
    required this.species,
    required this.weight,
    required this.hasDehydration,
    this.rehydrationTime,
    this.dehydrationPercent,
    required this.maintenanceVolume,
    this.rehydrationVolume,
    required this.totalDailyVolume,
    required this.infusionRateMlPerHour,
    required this.dropsPerMinute,
    required this.secondsBetweenDrops,
  });

  /// Cria um cálculo de fluidoterapia baseado nos parâmetros
  factory FluidCalculation.calculate({
    required String species,
    required double weight,
    required bool hasDehydration,
    int? rehydrationTime,
    double? dehydrationPercent,
  }) {
    // Taxa de manutenção por espécie
    final maintenanceRate = species == 'Cão' ? 60.0 : 40.0; // mL/kg/dia
    final maintenanceVolume = weight * maintenanceRate;

    double totalVolume = maintenanceVolume;
    double? rehydrationVolume;

    // Cálculo de reidratação se necessário
    if (hasDehydration && dehydrationPercent != null && rehydrationTime != null) {
      rehydrationVolume = weight * (dehydrationPercent / 100) * 1000;
      totalVolume = maintenanceVolume + (rehydrationVolume / (rehydrationTime / 24));
    }

    // Taxa de infusão em mL/h
    final infusionRate = totalVolume / 24;

    // Gotas por minuto (macrogotas = 20 gotas/mL)
    final dropsPerMinute = infusionRate * 20 / 60;

    // Tempo entre gotas em segundos
    final secondsBetweenDrops = dropsPerMinute > 0 ? (60 / dropsPerMinute).toDouble() : 0.0;

    return FluidCalculation(
      species: species,
      weight: weight,
      hasDehydration: hasDehydration,
      rehydrationTime: rehydrationTime,
      dehydrationPercent: dehydrationPercent,
      maintenanceVolume: maintenanceVolume,
      rehydrationVolume: rehydrationVolume,
      totalDailyVolume: totalVolume,
      infusionRateMlPerHour: infusionRate,
      dropsPerMinute: dropsPerMinute,
      secondsBetweenDrops: secondsBetweenDrops,
    );
  }
}
