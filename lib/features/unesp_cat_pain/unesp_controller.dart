import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/pain_assessment.dart';

class UnespController {
  final List<UnespPainAssessment> _history = [];
  static const String _prefsKey = 'ufeps_history_v1';

  List<UnespPainAssessment> get history => List.unmodifiable(_history);

  Future<void> loadHistory() async {
    final sp = await SharedPreferences.getInstance();
    final data = sp.getString(_prefsKey);
    if (data == null || data.isEmpty) return;
    try {
      final List<dynamic> decoded = json.decode(data) as List<dynamic>;
      _history.clear();
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          _history.add(UnespPainAssessment.fromMap(item));
        } else if (item is Map) {
          _history.add(UnespPainAssessment.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    } catch (e) {
      // ignore errors and keep history empty
    }
  }

  Future<void> _persistHistory() async {
    final sp = await SharedPreferences.getInstance();
    final data = json.encode(_history.map((e) => e.toMap()).toList());
    await sp.setString(_prefsKey, data);
  }

  Future<void> saveAssessment(UnespPainAssessment assessment) async {
    _history.insert(0, assessment);
    await _persistHistory();
  }

  String exportAssessment(UnespPainAssessment assessment) {
    return assessment.toCsv();
  }

  String exportAllCsv() {
    if (_history.isEmpty) return '';
    final all = _history.map((a) => a.toMap()).toList();
    final headers = all.first.keys.join(',');
    final rows = all.map((m) => m.values.map((v) => '"$v"').join(',')).join('\n');
    return '$headers\n$rows';
  }
}
