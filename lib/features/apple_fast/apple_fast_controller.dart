import 'package:flutter/foundation.dart';
// Using timestamp-based ids to avoid adding a new dependency
import '../apple/apple_storage_service.dart';
import 'dart:math' as math;

class AppleFastController with ChangeNotifier {
  double? glucose; // mg/dL
  double? albumin; // g/dL
  int mentationScore = 0; // 0-4
  double? plateletCount; // x10^3/uL
  double? lactate; // mmol/L

  int get totalScore {
    // Placeholder sum - replace with study point mapping
    final s = (glucose ?? 0) + (albumin ?? 0) + mentationScore + (plateletCount ?? 0) + (lactate ?? 0);
    return s.round();
  }

  double get mortalityProbability {
    // NOTE: coefficient for APPLE Fast should be replaced with study value.
    final r = -7.95 + 0.11 * totalScore;
    final er = math.exp(r);
    return er / (1 + er);
  }

  Future<void> saveToHistory() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final json = {
      'id': id,
      'type': 'apple_fast',
      'timestamp': DateTime.now().toIso8601String(),
      'inputs': {
        'glucose': glucose,
        'albumin': albumin,
        'mentationScore': mentationScore,
        'plateletCount': plateletCount,
        'lactate': lactate,
      },
      'results': {
        'score': totalScore,
        'mortality': mortalityProbability,
      }
    };

    await AppleStorageService.save(id, json);
  }
}
