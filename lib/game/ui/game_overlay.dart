import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gymborn_app/game/gym_game.dart';

class GameOverlay extends Component with HasGameReference<GymGame> {
  // UI elements
  final TextPaint _scorePaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
  );

  final TextPaint _healthPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  );

  // Game stats to display
  int _score = 0;
  double _health = 100;
  double _maxHealth = 100;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render score at top right
    _scorePaint.render(
      canvas,
      'Score: $_score',
      Vector2(game.size.x - 20, 20),
      anchor: Anchor.topRight,
    );

    // Render health bar at top left
    final healthBarWidth = 150.0;
    final healthBarHeight = 20.0;
    final healthPercentage = _health / _maxHealth;

    // Health bar background
    canvas.drawRect(
      Rect.fromLTWH(20, 20, healthBarWidth, healthBarHeight),
      Paint()..color = Colors.grey.shade800,
    );

    // Health bar fill
    canvas.drawRect(
      Rect.fromLTWH(20, 20, healthBarWidth * healthPercentage, healthBarHeight),
      Paint()..color = _getHealthColor(healthPercentage),
    );

    // Health text
    _healthPaint.render(
      canvas,
      '${_health.toInt()}/${_maxHealth.toInt()}',
      Vector2(20 + healthBarWidth / 2, 20 + healthBarHeight / 2),
      anchor: Anchor.center,
    );
  }

  Color _getHealthColor(double percentage) {
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }

  void updateScore(int score) {
    _score = score;
  }

  void updateHealth(double health, double maxHealth) {
    _health = health;
    _maxHealth = maxHealth;
  }
}
