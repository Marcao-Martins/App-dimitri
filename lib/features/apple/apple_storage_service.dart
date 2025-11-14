import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class AppleStorageService {
  static const _boxName = 'apple_scores';
  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Future<void> save(String id, Map<String, dynamic> json) async {
    if (_box == null) throw Exception('AppleStorageService not initialized');
    await _box!.put(id, jsonEncode(json));
  }

  static List<Map<String, dynamic>> loadAll() {
    if (_box == null) throw Exception('AppleStorageService not initialized');
    final out = <Map<String, dynamic>>[];
    for (final key in _box!.keys) {
      final s = _box!.get(key);
      if (s == null) continue;
      try {
        out.add(Map<String, dynamic>.from(jsonDecode(s)));
      } catch (e) {
        continue;
      }
    }
    return out;
  }

  static Future<void> clear() async {
    if (_box == null) throw Exception('AppleStorageService not initialized');
    await _box!.clear();
  }
}
