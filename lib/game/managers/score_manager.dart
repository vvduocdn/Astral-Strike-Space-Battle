class ScoreManager {
  int _score = 0;
  double _multiplier = 1.0;
  double _multiplierTimer = 0;

  int get score => _score;
  double get multiplier => _multiplier;

  void addScore(int points) {
    _score += (points * _multiplier).round();
  }

  void activateMultiplier(double value, double duration) {
    _multiplier = value;
    _multiplierTimer = duration;
  }

  void update(double dt) {
    if (_multiplierTimer > 0) {
      _multiplierTimer -= dt;
      if (_multiplierTimer <= 0) {
        _multiplier = 1.0;
      }
    }
  }

  void reset() {
    _score = 0;
    _multiplier = 1.0;
    _multiplierTimer = 0;
  }
}
