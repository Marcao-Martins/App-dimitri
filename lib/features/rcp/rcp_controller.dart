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

  // Peso do animal para cálculo de volumes de fármacos (kg)
  double? _weightKg;

  // Volumes calculados (ml)
  double _atropineVolumeMl = 0.0;
  double _adrenalineVolumeMl = 0.0;
  double _lidocaineVolumeMl = 0.0;

  RcpController() {
    WidgetsBinding.instance.addObserver(this);
    _setupAudio();
  }

  // Getters for weight and computed volumes
  double? get weightKg => _weightKg;
  double get atropineVolumeMl => _atropineVolumeMl;
  double get adrenalineVolumeMl => _adrenalineVolumeMl;
  double get lidocaineVolumeMl => _lidocaineVolumeMl;

  /// Define o peso (aceita null para limpar) e recalcula volumes
  void setWeightKg(double? kg) {
    _weightKg = kg;
    _recalculateVolumes();
    notifyListeners();
  }

  /// Recebe string do campo de texto (ex: '3.5' ou '3,5') e atualiza o peso
  void setWeightFromString(String value) {
    final cleaned = value.replaceAll(',', '.').trim();
    final parsed = double.tryParse(cleaned);
    setWeightKg(parsed);
  }

  void _recalculateVolumes() {
    // Doses padrão
    const double atropineDoseMgPerKg = 0.04; // mg/kg
    const double adrenalineDoseMgPerKg = 0.01; // mg/kg (ajustada conforme solicitado)
    const double lidocaineDoseMgPerKg = 2.0; // mg/kg

    // Concentrações
    const double atropineConcentrationMgPerMl = 10.0; // 10 mg/ml
    const double adrenalineConcentrationMgPerMl = 1.0; // 1 mg/ml
    const double lidocaineConcentrationMgPerMl = 20.0; // 20 mg/ml (apenas para cálculo)

    if (_weightKg == null || _weightKg! <= 0) {
      _atropineVolumeMl = 0.0;
      _adrenalineVolumeMl = 0.0;
      _lidocaineVolumeMl = 0.0;
      return;
    }

    final w = _weightKg!;
    final atropineTotalMg = w * atropineDoseMgPerKg;
    final adrenalineTotalMg = w * adrenalineDoseMgPerKg;

    _atropineVolumeMl = atropineTotalMg / atropineConcentrationMgPerMl;
    _adrenalineVolumeMl = adrenalineTotalMg / adrenalineConcentrationMgPerMl;
    final lidocaineTotalMg = w * lidocaineDoseMgPerKg;
    _lidocaineVolumeMl = lidocaineTotalMg / lidocaineConcentrationMgPerMl;
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
    debugPrint('RCP: startStop() called. isRunning=$_isRunning');
    if (_isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  /// Inicia o timer
  void _start() {
    _isRunning = true;

    debugPrint('RCP: _start() - starting timer');

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

    debugPrint('RCP: _pause() - timer paused');

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

    debugPrint('RCP: reset() called');
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
    debugPrint('RCP: toggleWakeLock() -> $_isWakeLockEnabled');

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
