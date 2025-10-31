/// Configurações específicas por espécie para o Escore Apgar
class SpeciesConfig {
  final String species;
  final String heartRateLabel;
  final List<ApgarOption> heartRateOptions;
  final String respiratoryLabel;
  final List<ApgarOption> respiratoryOptions;

  const SpeciesConfig({
    required this.species,
    required this.heartRateLabel,
    required this.heartRateOptions,
    required this.respiratoryLabel,
    required this.respiratoryOptions,
  });

  /// Configuração para gatos
  static const cat = SpeciesConfig(
    species: 'Gato',
    heartRateLabel: 'Frequência Cardíaca (FC)',
    heartRateOptions: [
      ApgarOption(score: 0, label: '<100 bpm', description: 'Bradicardia severa'),
      ApgarOption(score: 1, label: '<180 bpm', description: 'Bradicardia'),
      ApgarOption(score: 2, label: '200-280 bpm', description: 'Normal'),
    ],
    respiratoryLabel: 'Esforços Respiratórios',
    respiratoryOptions: [
      ApgarOption(score: 0, label: 'Ausente ou <10 mpm', description: 'Apneia'),
      ApgarOption(score: 1, label: 'Fraco ou <40 mpm', description: 'Bradipneia'),
      ApgarOption(score: 2, label: 'Regular 40-160 mpm', description: 'Normal'),
    ],
  );

  /// Configuração para cães
  static const dog = SpeciesConfig(
    species: 'Cão',
    heartRateLabel: 'Frequência Cardíaca (FC)',
    heartRateOptions: [
      ApgarOption(score: 0, label: '<180 bpm', description: 'Bradicardia severa'),
      ApgarOption(score: 1, label: '180-220 bpm', description: 'Normal baixo'),
      ApgarOption(score: 2, label: '>220 bpm', description: 'Normal'),
    ],
    respiratoryLabel: 'Esforços Respiratórios',
    respiratoryOptions: [
      ApgarOption(score: 0, label: 'Ausente ou <6 mpm', description: 'Apneia'),
      ApgarOption(score: 1, label: 'Fraco 6-15 mpm', description: 'Bradipneia'),
      ApgarOption(score: 2, label: 'Forte >15 mpm', description: 'Normal'),
    ],
  );

  /// Retorna a configuração baseada na espécie selecionada
  static SpeciesConfig getConfig(String species) {
    return species == 'Gato' ? cat : dog;
  }
}

/// Opção de pontuação para um parâmetro
class ApgarOption {
  final int score;
  final String label;
  final String description;

  const ApgarOption({
    required this.score,
    required this.label,
    required this.description,
  });
}
