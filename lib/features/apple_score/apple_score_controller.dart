import 'package:flutter/foundation.dart';
import 'apple_score_model.dart';

/// Controller para gerenciar o estado do APPLE Score
class AppleScoreController extends ChangeNotifier {
  AppleScore _score = AppleScore();

  AppleScore get score => _score;

  /// Atualiza o valor de Atitude/Comportamento
  void updateAttitude(int value) {
    _score = _score.copyWith(attitude: value);
    notifyListeners();
  }

  /// Atualiza o valor de Comfort/Conforto
  void updateComfort(int value) {
    _score = _score.copyWith(comfort: value);
    notifyListeners();
  }

  /// Atualiza o valor de Postura
  void updatePosture(int value) {
    _score = _score.copyWith(posture: value);
    notifyListeners();
  }

  /// Atualiza o valor de Vocalização
  void updateVocalization(int value) {
    _score = _score.copyWith(vocalization: value);
    notifyListeners();
  }

  /// Atualiza o valor de Resposta à Palpação
  void updatePalpation(int value) {
    _score = _score.copyWith(palpation: value);
    notifyListeners();
  }

  /// Reseta todos os valores para zero
  void reset() {
    _score = AppleScore();
    notifyListeners();
  }

  /// Verifica se há algum valor selecionado
  bool get hasAnySelection =>
      _score.attitude > 0 ||
      _score.comfort > 0 ||
      _score.posture > 0 ||
      _score.vocalization > 0 ||
      _score.palpation > 0;
}
