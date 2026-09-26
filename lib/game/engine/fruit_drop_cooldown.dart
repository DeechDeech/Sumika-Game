abstract final class FruitDropCooldownConstants {
  static const double durationSeconds = 0.35;
  static const double readyThreshold = 0;
  static const double initialRemainingSeconds = 0;
}

class FruitDropCooldown {
  double _remainingSeconds = FruitDropCooldownConstants.initialRemainingSeconds;

  /// クールタイム中でなければ投下を許可し、待ち時間を開始します。
  bool tryStart() {
    if (_remainingSeconds > FruitDropCooldownConstants.readyThreshold) {
      return false;
    }
    _remainingSeconds = FruitDropCooldownConstants.durationSeconds;
    return true;
  }

  /// Flame の経過時間分だけ残り時間を減らします。
  void advance(double deltaSeconds) {
    _remainingSeconds -= deltaSeconds;
    if (_remainingSeconds < FruitDropCooldownConstants.readyThreshold) {
      _remainingSeconds = FruitDropCooldownConstants.readyThreshold;
    }
  }

  /// リセット後に果実をすぐ投下できる状態へ戻します。
  void reset() {
    _remainingSeconds = FruitDropCooldownConstants.initialRemainingSeconds;
  }
}
