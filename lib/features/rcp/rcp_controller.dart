import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Controller para o módulo RCP Coach
/// Gerencia timer de 2 minutos, ciclos, áudio contínuo e wake lock
class RcpController with ChangeNotifier, WidgetsBindingObserver {
  // Timer
  static const int cycleDuration = 120; // 2 minutos em segundos
  Timer? _countdownTimer;
  int _secondsRemaining = cycleDuration;
  bool _isRunning = false;

  // Cycles
  int _cycleCount = 0;

  // Audio
  final AudioPlayer _beepPlayer = AudioPlayer();
  static const String _beepSound = 'sounds/beep.mp3';
  bool _audioInitialized = false;

  // Wake Lock (tela sempre ligada)
  bool _isWakeLockEnabled = false;

  RcpController() {
    WidgetsBinding.instance.addObserver(this);
    _setupAudio();
  }

  // Getters
  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;
  int get cycleCount => _cycleCount;
  bool get isWakeLockEnabled => _isWakeLockEnabled;
  double get progress => 1.0 - (_secondsRemaining / cycleDuration);

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

  /// Inicia o timer
  void _start() {
    _isRunning = true;

    // Inicia o áudio em loop
    _playBeep();

    // Timer principal de contagem regressiva (1 segundo)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      } else {
        _cycleCompleted();
      }
      notifyListeners();
    });

    notifyListeners();
  }

  /// Pausa o timer
  void _pause() {
    _isRunning = false;
    _countdownTimer?.cancel();

    // Para o áudio
    _stopBeep();

    notifyListeners();
  }

  /// Pausa pública — exposta para widgets que queiram pausar o controlador
  void pauseTimer() {
    _pause();
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
    _secondsRemaining = cycleDuration; // Reset para próximo ciclo
    // Timer continua rodando automaticamente
    notifyListeners();
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

  /// Configuração inicial do áudio
  Future<void> _setupAudio() async {
    try {
      await _beepPlayer.setReleaseMode(ReleaseMode.loop);
      await _beepPlayer.setSource(AssetSource(_beepSound));
      _audioInitialized = true;
    } catch (e) {
      debugPrint('RCP audio setup error: $e');
      _audioInitialized = false;
    }
  }

  /// Inicia o áudio em loop
  Future<void> _playBeep() async {
    if (!_audioInitialized) return;

    try {
      await _beepPlayer.resume();
    } catch (e) {
      debugPrint('RCP play error: $e');
    }
  }

  /// Para o áudio
  Future<void> _stopBeep() async {
    try {
      await _beepPlayer.pause();
    } catch (e) {
      debugPrint('RCP stop error: $e');
    }
  }

  /// Detecta quando o app vai para background ou usuário troca de aba
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Para o áudio quando app vai para background ou troca de aba
      if (_isRunning) {
        _stopBeep();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Retoma o áudio quando volta para o app (se estava rodando)
      if (_isRunning) {
        _playBeep();
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _beepPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // Desativa wake lock ao sair
    WakelockPlus.disable();
    super.dispose();
  }
}
