import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/audio/sound_registry.dart';

/// Utility to manage beeps used by the Ficha Anestésica.
///
/// Usage:
///   final bm = BeepManager.instance;
///   await bm.init(); // optional: preloads assets
///   await bm.playBeep(); // default short beep (uses assets/sounds/beep.mp3)
///   await bm.playAlternateBeep(); // plays alternate sound (assets/sounds/cycle_end.mp3)
///
/// Notes:
/// - The assets referenced here must be present in `assets/sounds/` and declared in pubspec.yaml.
/// - This wrapper keeps a single AudioPlayer instance and provides convenience methods
///   for short beep sequences. It is intentionally small and dependency-free beyond
///   `audioplayers`, to be easily used from `FichaProvider` or other widgets.
class BeepManager {
  BeepManager._private();

  static final BeepManager instance = BeepManager._private();

  final AudioPlayer _player = AudioPlayer();
  static const String _prefsKey = 'ficha_beep_choice';

  /// 'primary' or 'alternate'
  String _selected = 'primary';

  /// Default asset paths (relative to `assets/` folder). Uses `SoundRegistry`.
  String primaryBeep = SoundRegistry.fichaBeep;
  String alternateBeep = SoundRegistry.cycleEnd;

  /// Initialize and preload common assets to reduce latency.
  /// Call once (for example in provider constructor) before expecting low-latency play.
  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      // Preload primary and alternate
      await _player.setSource(AssetSource(primaryBeep));
      await _player.setSource(AssetSource(alternateBeep));
      // Load persisted selection
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString(_prefsKey);
        if (stored != null && (stored == 'primary' || stored == 'alternate')) {
          _selected = stored;
        }
      } catch (_) {}
    } catch (e) {
      // ignore preload failures; play methods will still attempt to play later
    }
  }

  /// Plays the primary short beep sequence (3 short beeps by default).
  /// [count] number of beeps, [beepMs] duration of each beep in milliseconds.
  Future<void> playBeep({int count = 3, int beepMs = 200}) async {
    try {
      for (int i = 0; i < count; i++) {
        await _player.setSource(AssetSource(primaryBeep));
        await _player.resume();
        await Future.delayed(Duration(milliseconds: beepMs));
        await _player.stop();
        if (i < count - 1) await Future.delayed(const Duration(milliseconds: 150));
      }
    } catch (e) {
      // Log or ignore; keep silent failure to avoid crashes in UI
    }
  }

  /// Plays an alternate sound (single shot). Useful for distinct alerts.
  Future<void> playAlternateBeep() async {
    try {
      await _player.setSource(AssetSource(alternateBeep));
      await _player.resume();
    } catch (e) {
      // ignore
    }
  }

  /// Play the currently selected beep (persisted choice).
  Future<void> playSelectedBeep({int count = 3, int beepMs = 200}) async {
    if (_selected == 'primary') {
      await playBeep(count: count, beepMs: beepMs);
    } else {
      await playAlternateBeep();
    }
  }

  /// Set the selected beep and persist the choice ('primary' or 'alternate').
  Future<void> setSelectedBeep(String which) async {
    if (which != 'primary' && which != 'alternate') return;
    _selected = which;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, which);
    } catch (_) {}
  }

  /// Get the currently selected beep id ('primary' or 'alternate')
  String getSelectedBeep() => _selected;

  /// Dispose underlying resources when app is shutting down.
  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
