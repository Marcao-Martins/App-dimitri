import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ficha_anestesica.dart';

class StorageService {
  static const String _fichasBoxName = 'fichas_anestesicas';
  static Box<String>? _fichasBox;

  /// Inicializa o Hive (chamar no main antes de runApp)
  static Future<void> init() async {
    await Hive.initFlutter();
    _fichasBox = await Hive.openBox<String>(_fichasBoxName);
  }

  /// Salva uma ficha
  static Future<void> saveFicha(String id, FichaAnestesica ficha) async {
    if (_fichasBox == null) throw Exception('StorageService not initialized');
    final json = jsonEncode(ficha.toJson());
    await _fichasBox!.put(id, json);
  }

  /// Carrega todas as fichas
  static List<FichaAnestesica> loadAllFichas() {
    if (_fichasBox == null) throw Exception('StorageService not initialized');
    final fichas = <FichaAnestesica>[];
    
    for (var key in _fichasBox!.keys) {
      try {
        final jsonStr = _fichasBox!.get(key);
        if (jsonStr != null) {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          fichas.add(FichaAnestesica.fromJson(json));
        }
      } catch (e) {
        // Skip corrupted entries
        continue;
      }
    }
    
    return fichas;
  }

  /// Carrega uma ficha por ID
  static FichaAnestesica? loadFicha(String id) {
    if (_fichasBox == null) throw Exception('StorageService not initialized');
    final jsonStr = _fichasBox!.get(id);
    if (jsonStr == null) return null;
    
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return FichaAnestesica.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Deleta uma ficha
  static Future<void> deleteFicha(String id) async {
    if (_fichasBox == null) throw Exception('StorageService not initialized');
    await _fichasBox!.delete(id);
  }

  /// Limpa todas as fichas (use com cuidado)
  static Future<void> clearAll() async {
    if (_fichasBox == null) throw Exception('StorageService not initialized');
    await _fichasBox!.clear();
  }
}
