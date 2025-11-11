/// Centraliza nomes de assets de áudio usados pela aplicação.
/// Permite referenciar sons por id ao invés de strings literais espalhadas.
enum SoundId { fichaBeep, rcpBeep, cycleEnd }

class SoundRegistry {
  SoundRegistry._();

  /// Retorna o caminho do asset relativo à pasta `assets/`.
  static String assetFor(SoundId id) {
    switch (id) {
      case SoundId.fichaBeep:
        return 'sounds/beep.mp3';
      case SoundId.rcpBeep:
        // RCP usa um beep contínuo; por padrão reutilizamos o mesmo beep,
        // mas mantemos separação para permitir troca futura.
        return 'sounds/beep.mp3';
      case SoundId.cycleEnd:
        return 'sounds/cycle_end.mp3';
    }
  }

  /// Helpful named getters
  static String get fichaBeep => assetFor(SoundId.fichaBeep);
  static String get rcpBeep => assetFor(SoundId.rcpBeep);
  static String get cycleEnd => assetFor(SoundId.cycleEnd);
}
