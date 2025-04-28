import '../models/enemy.dart';
import 'dart:math';

class EnemyFactory {
  final Random _random = Random();

  // Regular enemy names
  final List<String> _regularEnemyNames = [
    'Lazy Lounger',
    'Cardio Dodger',
    'Weight Skipper',
    'Donut Destroyer',
    'Protein Thief',
    'Gym Hog',
    'Machine Misuser',
    'Form Breaker',
  ];

  // Boss names
  final List<String> _bossNames = [
    'Gym Titan',
    'Iron Master',
    'Fitness Overlord',
    'Muscle Mountain',
    'Cardio King',
  ];

  // Create a regular enemy with difficulty based on level
  Enemy createEnemy(int level, double difficultyMultiplier) {
    final name = _regularEnemyNames[_random.nextInt(_regularEnemyNames.length)];

    // Scale stats based on level and difficulty
    final baseHealth = 50 + (level * 20);
    final health = (baseHealth * difficultyMultiplier).round();

    final baseStrength = 5 + (level * 2);
    final strength = (baseStrength * difficultyMultiplier).round();

    return Enemy(
      id:
          'enemy_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      name: name,
      health: health,
      maxHealth: health,
      strength: strength,
      isBoss: false,
    );
  }

  // Create a boss enemy with significantly higher stats
  Enemy createBoss(int level, double difficultyMultiplier) {
    final name = _bossNames[_random.nextInt(_bossNames.length)];

    // Bosses are much stronger than regular enemies
    final baseHealth = 200 + (level * 50);
    final health = (baseHealth * difficultyMultiplier).round();

    final baseStrength = 15 + (level * 5);
    final strength = (baseStrength * difficultyMultiplier).round();

    return Enemy(
      id: 'boss_${DateTime.now().millisecondsSinceEpoch}',
      name: '$name, the Level $level Boss',
      health: health,
      maxHealth: health,
      strength: strength,
      isBoss: true,
    );
  }
}
