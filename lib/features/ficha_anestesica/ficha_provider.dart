import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/ficha_anestesica.dart';
import 'models/paciente.dart';
import 'models/medicacao.dart';
import 'models/parametro_monitorizacao.dart';
import 'models/intercorrencia.dart';
import 'models/farmaco_intraoperatorio.dart';
import 'services/storage_service.dart';

/// Provider para gerenciar o estado da Ficha Anestésica com persistência Hive.
class FichaProvider extends ChangeNotifier {
  List<FichaAnestesica> _fichas = [];
  FichaAnestesica? _current;
  String? _currentId;
  
  // Gerenciamento do cronômetro
  Timer? _procedureTimer;
  bool _isTimerRunning = false;
  
  // Gerenciamento do alarme de monitorização
  Timer? _alarmeTimer;
  bool _alarmeAtivo = false;
  int _intervaloMinutos = 5;
  DateTime? _proximoAlarme;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Callback para notificação visual
  Function()? _onAlarmeTocar;

  List<FichaAnestesica> get fichas => List.unmodifiable(_fichas);
  FichaAnestesica? get current => _current;
  bool get isTimerRunning => _isTimerRunning;
  int get procedureTimeSeconds => _current?.procedureTimeSeconds ?? 0;
  
  // Getters para alarme
  bool get alarmeAtivo => _alarmeAtivo;
  int get intervaloMinutos => _intervaloMinutos;
  DateTime? get proximoAlarme => _proximoAlarme;

  FichaProvider() {
    _loadAllFichas();
    _setupAudio();
  }
  
  @override
  void dispose() {
    _procedureTimer?.cancel();
    _alarmeTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadAllFichas() {
    try {
      _fichas = StorageService.loadAllFichas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading fichas: $e');
    }
  }

  /// Configuração inicial do player de áudio e pré-carregamento do beep
  Future<void> _setupAudio() async {
    try {
      // Para permitir toques consecutivos sem loop automático
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      // Pré-carrega a fonte para reduzir latência
      await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
    } catch (e) {
      debugPrint('Erro na configuração do áudio: $e');
    }
  }

  void createNew(Paciente paciente) {
    _current = FichaAnestesica(paciente: paciente);
    _currentId = DateTime.now().millisecondsSinceEpoch.toString();
    _stopTimer(); // Para o timer anterior se houver
    notifyListeners();
  }

  void load(FichaAnestesica ficha, String id) {
    _current = ficha;
    _currentId = id;
    _stopTimer(); // Para o timer anterior
    
    // Se a ficha tinha o timer rodando, reinicia
    if (ficha.timerWasRunning) {
      startTimer();
    }
    
    notifyListeners();
  }

  Future<void> saveCurrent() async {
    if (_current == null || _currentId == null) return;
    
    try {
      await StorageService.saveFicha(_currentId!, _current!);
      
      // Atualizar lista local
      final index = _fichas.indexWhere((f) => f.paciente.nome == _current!.paciente.nome);
      if (index >= 0) {
        _fichas[index] = _current!;
      } else {
        _fichas.add(_current!);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving ficha: $e');
      rethrow;
    }
  }

  Future<void> deleteFicha(String id) async {
    try {
      await StorageService.deleteFicha(id);
      _loadAllFichas();
    } catch (e) {
      debugPrint('Error deleting ficha: $e');
      rethrow;
    }
  }

  void addParametro(ParametroMonitorizacao p) {
    _current?.parametros.add(p);
    notifyListeners();
  }

  void removeParametroAt(int index) {
    _current?.parametros.removeAt(index);
    notifyListeners();
  }

  void updateParametro(int index, ParametroMonitorizacao p) {
    if (_current != null && index < _current!.parametros.length) {
      _current!.parametros[index] = p;
      notifyListeners();
    }
  }

  void addMedicacaoTo(List<Medicacao> list, Medicacao med) {
    list.add(med);
    notifyListeners();
  }

  void removeMedicacaoFrom(List<Medicacao> list, int index) {
    if (index < list.length) {
      list.removeAt(index);
      notifyListeners();
    }
  }

  /// Atualiza uma medicação existente na lista (usado pelo DynamicTable ao editar)
  void updateMedicacaoIn(List<Medicacao> list, int index, Medicacao updated) {
    if (index < 0 || index >= list.length) return;
    list[index] = updated;
    notifyListeners();
  }

  void addIntercorrencia(String descricao, DateTime momento, String gravidade) {
    if (_current == null) return;
    
    final intercorrencia = Intercorrencia(
      momento: momento,
      descricao: descricao,
      gravidade: gravidade,
    );
    
    _current!.intercorrencias.add(intercorrencia);
    notifyListeners();
  }

  void removeIntercorrencia(int index) {
    if (_current != null && index < _current!.intercorrencias.length) {
      _current!.intercorrencias.removeAt(index);
      notifyListeners();
    }
  }

  void addFarmacoIntraoperatorio(
    String nome,
    double dose,
    String unidade,
    String via,
    DateTime hora,
  ) {
    if (_current == null) return;
    
    final farmaco = FarmacoIntraoperatorio(
      nome: nome,
      dose: dose,
      unidade: unidade,
      via: via,
      hora: hora,
    );
    
    _current!.farmacosIntraoperatorios.add(farmaco);
    notifyListeners();
  }

  void removeFarmacoIntraoperatorio(int index) {
    if (_current != null && index < _current!.farmacosIntraoperatorios.length) {
      _current!.farmacosIntraoperatorios.removeAt(index);
      notifyListeners();
    }
  }

  // ============ MÉTODOS DO CRONÔMETRO ============
  
  void startTimer() {
    if (_isTimerRunning || _current == null) return;
    
    _isTimerRunning = true;
    _current!.timerWasRunning = true;
    
    _procedureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_current != null) {
        _current!.procedureTimeSeconds++;
        notifyListeners();
      }
    });
    
    notifyListeners();
  }
  
  void pauseTimer() {
    if (!_isTimerRunning) return;
    
    _procedureTimer?.cancel();
    _isTimerRunning = false;
    
    if (_current != null) {
      _current!.timerWasRunning = false;
    }
    
    notifyListeners();
  }
  
  void stopTimer() {
    _procedureTimer?.cancel();
    _isTimerRunning = false;
    
    if (_current != null) {
      _current!.timerWasRunning = false;
    }
    
    notifyListeners();
  }
  
  void resetTimer() {
    _stopTimer();
    
    if (_current != null) {
      _current!.procedureTimeSeconds = 0;
      _current!.timerWasRunning = false;
    }
    
    notifyListeners();
  }
  
  void _stopTimer() {
    _procedureTimer?.cancel();
    _isTimerRunning = false;
  }
  
  bool get hasTimerStarted => _current != null && _current!.procedureTimeSeconds > 0;

  void updateTimerState(int seconds, bool isRunning) {
    if (_current != null) {
      _current!.procedureTimeSeconds = seconds;
      _current!.timerWasRunning = isRunning;
      notifyListeners();
    }
  }

  void clearCurrent() {
    _stopTimer(); // Para o timer antes de limpar
    _pararAlarme(); // Para o alarme antes de limpar
    _current = null;
    _currentId = null;
    notifyListeners();
  }
  
  // ===== MÉTODOS DE ALARME DE MONITORIZAÇÃO =====
  
  /// Define callback para quando o alarme tocar
  void setAlarmeCallback(Function() callback) {
    _onAlarmeTocar = callback;
  }
  
  /// Inicia o alarme de monitorização
  void iniciarAlarme() {
    _alarmeTimer?.cancel();
    
    _alarmeAtivo = true;
    _proximoAlarme = DateTime.now().add(Duration(minutes: _intervaloMinutos));

    // Desbloqueia o contexto de áudio no web (requer gesto do usuário)
    // Faz um play rápido e parado imediatamente para liberar autoplay policies
    _primeAudioForWeb();
    
    _alarmeTimer = Timer.periodic(Duration(minutes: _intervaloMinutos), (timer) {
      if (_alarmeAtivo) {
        _tocarBeep();
        _onAlarmeTocar?.call(); // Notifica o widget
        _proximoAlarme = DateTime.now().add(Duration(minutes: _intervaloMinutos));
        notifyListeners();
      }
    });
    
    notifyListeners();
  }
  
  /// Para o alarme de monitorização
  void pararAlarme() {
    _pararAlarme();
    notifyListeners();
  }
  
  void _pararAlarme() {
    _alarmeTimer?.cancel();
    _alarmeAtivo = false;
    _proximoAlarme = null;
  }
  
  /// Altera o intervalo do alarme
  void setIntervaloAlarme(int minutos) {
    _intervaloMinutos = minutos;
    if (_alarmeAtivo) {
      _pararAlarme();
      iniciarAlarme();
    }
    notifyListeners();
  }
  
  /// Toca o beep de alerta (3 beeps curtos)
  Future<void> _tocarBeep() async {
    try {
      // Garante a fonte definida (caso player tenha sido reiniciado)
      await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));

      for (int i = 0; i < 3; i++) {
        // Inicia o beep
        await _audioPlayer.resume();
        // Mantém curto; interrompe antes do fim para efeito de beep
        await Future.delayed(const Duration(milliseconds: 200));
        await _audioPlayer.stop();
        // Pequena pausa entre os beeps
        await Future.delayed(const Duration(milliseconds: 150));
      }
    } catch (e) {
      debugPrint('Erro ao tocar beep: $e');
    }
  }

  /// Faz um play silencioso imediato para "desbloquear" áudio no Web (autoplay policies)
  Future<void> _primeAudioForWeb() async {
    try {
      // Volume zero, toca rapidamente e para. Depois restaura volume padrão (1.0)
      await _audioPlayer.setVolume(0.0);
      await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
      await _audioPlayer.resume();
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      // Mesmo que falhe aqui, o alarme seguirá tentando tocar depois
      debugPrint('Falha ao primar áudio: $e');
    }
  }
  
  /// Calcula tempo restante até próximo alarme
  String getTempoRestanteAlarme() {
    if (_proximoAlarme == null) return '';
    
    final agora = DateTime.now();
    final diferenca = _proximoAlarme!.difference(agora);
    
    if (diferenca.isNegative) return 'Próximo alarme';
    
    final minutos = diferenca.inMinutes;
    final segundos = diferenca.inSeconds % 60;
    
    return '${minutos}:${segundos.toString().padLeft(2, '0')}';
  }
  
  // ========== GERENCIAMENTO DE IMAGENS ==========
  
  /// Adiciona uma imagem à ficha atual
  void addImage(String imagePath) {
    if (_current == null) return;
    
    _current!.imagePaths.add(imagePath);
    notifyListeners();
  }
  
  /// Remove uma imagem da ficha atual
  void removeImage(String imagePath) {
    if (_current == null) return;
    
    _current!.imagePaths.remove(imagePath);
    notifyListeners();
  }
  
  /// Obtém lista de imagens da ficha atual
  List<String> get currentImagePaths => _current?.imagePaths ?? [];

  // ===== Manejo de Vias Aéreas =====
  void setAirwayIntubation(String? value) {
    if (_current == null) return;
    _current!.airwayIntubation = value;
    notifyListeners();
  }

  void setAirwayTubeSize(String? value) {
    if (_current == null) return;
    _current!.airwayTubeSize = value;
    notifyListeners();
  }

  void setAirwayPreOxygenation(String? value) {
    if (_current == null) return;
    _current!.airwayPreOxygenation = value;
    notifyListeners();
  }

  void setAirwayPeriglotticAnesthesia(String? value) {
    if (_current == null) return;
    _current!.airwayPeriglotticAnesthesia = value;
    notifyListeners();
  }

  void setAirwayLaryngealMask(String? value) {
    if (_current == null) return;
    _current!.airwayLaryngealMask = value;
    notifyListeners();
  }

  void setAirwayObservations(String? value) {
    if (_current == null) return;
    _current!.airwayObservations = value;
    notifyListeners();
  }
}

