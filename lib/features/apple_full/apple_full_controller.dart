import 'package:flutter/foundation.dart';
import 'dart:math' as math;
// Using timestamp-based ids to avoid adding a new dependency
import '../apple/apple_storage_service.dart';

class AppleFullController with ChangeNotifier {
  // Inputs
  double? creatinine; // mg/dL
  double? wbcCount; // x10^3/uL
  double? albumin; // g/dL
  double? spo2; // %
  double? totalBilirubin; // mg/dL
  int mentationScore = 0; // 0-4
  int? respiratoryRate; // breaths per minute
  int? ageYears; // years
  double? lactate; // mmol/L
  int fluidScore = 0; // 0-2

  // Placeholder for per-variable point logic. These should be implemented
  // using the study tables. For now these functions return 0 and must be
  // replaced with the precise point allocations.
  double _pointsFromCreatinine() => 0.0;
  double _pointsFromWbc() => 0.0;
  double _pointsFromAlbumin() => 0.0;
  double _pointsFromSpO2() => 0.0;
  double _pointsFromBilirubin() => 0.0;
  double _pointsFromMentation() => mentationScore.toDouble();
  double _pointsFromRespiratoryRate() => 0.0;
  double _pointsFromAge() => 0.0;
  double _pointsFromLactate() => 0.0;
  double _pointsFromFluidScore() => fluidScore.toDouble();

  int get totalScore {
    // Sum all variable points (placeholders)
    final s = _pointsFromCreatinine() +
        _pointsFromWbc() +
        _pointsFromAlbumin() +
        _pointsFromSpO2() +
        _pointsFromBilirubin() +
        _pointsFromMentation() +
        _pointsFromRespiratoryRate() +
        _pointsFromAge() +
        _pointsFromLactate() +
        _pointsFromFluidScore();
    return s.round();
  }

  double get mortalityProbability {
    // Logistic equation from the study example: R = -7.95 + 0.11 × score
    final r = -7.95 + 0.11 * totalScore;
    final er = math.exp(r);
    final p = er / (1 + er);
    return p;
  }

  /// Save a calculation to history (uses AppleStorageService)
  Future<void> saveToHistory() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final json = {
      'id': id,
      'type': 'apple_full',
      'timestamp': DateTime.now().toIso8601String(),
      'inputs': {
        'creatinine': creatinine,
        'wbcCount': wbcCount,
        'albumin': albumin,
        'spo2': spo2,
        'totalBilirubin': totalBilirubin,
        'mentationScore': mentationScore,
        'respiratoryRate': respiratoryRate,
        'ageYears': ageYears,
        'lactate': lactate,
        'fluidScore': fluidScore,
      },
      'results': {
        'score': totalScore,
        'mortality': mortalityProbability,
      }
    };

    await AppleStorageService.save(id, json);
  }
}

// Note: the per-variable point mappings are placeholders and must be
// implemented following the study's published tables to obtain valid
// APPLE Full scores. This controller provides the structure and
// persistence helper for history.
