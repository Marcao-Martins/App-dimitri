import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Controller para o módulo RCP Coach
/// Gerencia timer de 2 minutos, áudio (metrônomo + alertas), ciclos e wake lock
class RcpController with ChangeNotifier {
  // Timer
  static const int cycleDuration = 120; // 2 minutos em segundos
  Timer? _countdownTimer;
  Timer? _metronomeTimer;
  Timer? _breathTimer;
  int _secondsRemaining = cycleDuration;
  bool _isRunning = false;

  // Cycles
  int _cycleCount = 0;

  // Audio
  final AudioPlayer _metronomePlayer = AudioPlayer();
  final AudioPlayer _alertPlayer = AudioPlayer();
  final AudioPlayer _breathPlayer = AudioPlayer();
  static const String _beepSound = 'sounds/beep.mp3';
  static const String _cycleEndSound = 'sounds/cycle_end.mp3';
  static const String _breathSound = 'sounds/breath.mp3'; // opcional; fallback para beep
  bool _isMuted = false;
  bool _hasBreathAsset = true;
  
  // Wake Lock (tela sempre ligada)
  bool _isWakeLockEnabled = false;

  // Getters
  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;
  int get cycleCount => _cycleCount;
  bool get isMuted => _isMuted;
  bool get isWakeLockEnabled => _isWakeLockEnabled;
  double get progress => 1.0 - (_secondsRemaining / cycleDuration);

  RcpController() {
    _setupAudio();
  }
  
  /// Retorna mensagem de status em tempo real
  String get statusMessage {
    if (!_isRunning && _secondsRemaining == cycleDuration) {
      return 'Pronto para iniciar';
    } else if (!_isRunning) {
      return 'Pausado - ${_formatTime(_secondsRemaining)} restante';
    } else if (_secondsRemaining > 110) {
      return 'Compressões torácicas - 100-120/min';
    } else if (_secondsRemaining > 0) {
      return 'Continue as compressões - ${_formatTime(_secondsRemaining)}';
    } else {
      return 'Ciclo completo! Avalie paciente';
    }
  }

  /// Formata segundos em MM:SS
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Inicia ou para o timer
  void startStop() {
    if (_isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  /// Inicia o timer e metrônomo
  void _start() {
    _isRunning = true;
    // Prime o áudio no web sob gesto do usuário
    _primeAudioForWeb();
    
    // Timer principal de contagem regressiva (1 segundo)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      } else {
        _cycleCompleted();
      }
      notifyListeners();
    });

    // Metrônomo para compressões (500ms = 120 BPM)
    _metronomeTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isRunning) {
        _playSound(_metronomePlayer, _beepSound, volume: 0.5);
      }
    });

    // Respiração a cada 6 segundos (≈10 bpm)
    _breathTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_isRunning) {
        final path = _hasBreathAsset ? _breathSound : _beepSound;
        _playSound(_breathPlayer, path, volume: 0.9);
      }
    });

    notifyListeners();
  }

  /// Pausa o timer e metrônomo
  void _pause() {
    _isRunning = false;
    _countdownTimer?.cancel();
    _metronomeTimer?.cancel();
    _breathTimer?.cancel();
    notifyListeners();
  }

  /// Reinicia tudo
  void reset() {
    _pause();
    _secondsRemaining = cycleDuration;
    _cycleCount = 0;
    notifyListeners();
  }

  /// Completou um ciclo de 2 minutos
  void _cycleCompleted() {
    _cycleCount++;
    _playSound(_alertPlayer, _cycleEndSound, volume: 1.0);
    _secondsRemaining = cycleDuration; // Reset para próximo ciclo
    // Timer continua rodando automaticamente
    notifyListeners();
  }

  /// Toggle mute/unmute
  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  /// Reproduz som com controle de volume
  Future<void> _playSound(AudioPlayer player, String soundPath, {double volume = 1.0}) async {
    if (!_isMuted) {
      await player.setVolume(volume);
      await player.play(AssetSource(soundPath));
    }
  }

  Future<void> _setupAudio() async {
    try {
      await _metronomePlayer.setReleaseMode(ReleaseMode.stop);
      await _alertPlayer.setReleaseMode(ReleaseMode.stop);
      await _breathPlayer.setReleaseMode(ReleaseMode.stop);
      // Pré-carrega fontes conhecidas
      await _metronomePlayer.setSource(AssetSource(_beepSound));
      await _alertPlayer.setSource(AssetSource(_cycleEndSound));
      try {
        await _breathPlayer.setSource(AssetSource(_breathSound));
        _hasBreathAsset = true;
      } catch (_) {
        _hasBreathAsset = false; // usar fallback
      }
    } catch (e) {
      debugPrint('RCP audio setup error: $e');
    }
  }

  Future<void> _primeAudioForWeb() async {
    try {
      await _metronomePlayer.setVolume(0.0);
      await _metronomePlayer.setSource(AssetSource(_beepSound));
      await _metronomePlayer.resume();
      await Future.delayed(const Duration(milliseconds: 80));
      await _metronomePlayer.stop();
      await _metronomePlayer.setVolume(0.5);
    } catch (_) {}
  }

  /// Toggle wake lock (manter tela sempre ligada)
  Future<void> toggleWakeLock() async {
    _isWakeLockEnabled = !_isWakeLockEnabled;
    
    if (_isWakeLockEnabled) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _metronomeTimer?.cancel();
    _breathTimer?.cancel();
    _metronomePlayer.dispose();
    _alertPlayer.dispose();
    _breathPlayer.dispose();
    // Desativa wake lock ao sair
    WakelockPlus.disable();
    super.dispose();
  }
}
