import 'package:flutter/material.dart';
import 'models/ficha_anestesica.dart';
import 'models/paciente.dart';
import 'models/medicacao.dart';
import 'models/parametro_monitorizacao.dart';
import 'models/intercorrencia.dart';
import 'services/storage_service.dart';

/// Provider para gerenciar o estado da Ficha Anestésica com persistência Hive.
class FichaProvider extends ChangeNotifier {
  List<FichaAnestesica> _fichas = [];
  FichaAnestesica? _current;
  String? _currentId;

  List<FichaAnestesica> get fichas => List.unmodifiable(_fichas);
  FichaAnestesica? get current => _current;

  FichaProvider() {
    _loadAllFichas();
  }

  void _loadAllFichas() {
    try {
      _fichas = StorageService.loadAllFichas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading fichas: $e');
    }
  }

  void createNew(Paciente paciente) {
    _current = FichaAnestesica(paciente: paciente);
    _currentId = DateTime.now().millisecondsSinceEpoch.toString();
    notifyListeners();
  }

  void load(FichaAnestesica ficha, String id) {
    _current = ficha;
    _currentId = id;
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

  void addIntercorrencia(Intercorrencia ic) {
    _current?.intercorrencias.add(ic);
    notifyListeners();
  }

  void clearCurrent() {
    _current = null;
    _currentId = null;
    notifyListeners();
  }
}
