import '../models/level.dart';
import '../models/enemy.dart';
import '../factories/enemy_factory.dart';

class LevelService {
  // Define all available levels
  static final List<Level> _levels = [
    Level(
      levelNumber: 1,
      name: 'Beginner\'s Path',
      description: 'A gentle introduction to your fitness journey.',
      enemyCount: 3,
      difficultyMultiplier: 1.0,
    ),
    Level(
      levelNumber: 2,
      name: 'Training Grounds',
      description: 'The intensity is picking up.',
      enemyCount: 5,
      difficultyMultiplier: 1.2,
    ),
    Level(
      levelNumber: 3,
      name: 'Endurance Trial',
      description: 'Your limits will be tested here.',
      enemyCount: 7,
      difficultyMultiplier: 1.5,
    ),
    Level(
      levelNumber: 4,
      name: 'Strength Challenge',
      description: 'Only the strong will prevail.',
      enemyCount: 9,
      difficultyMultiplier: 1.8,
    ),
    Level(
      levelNumber: 5,
      name: 'Champion\'s Arena',
      description: 'Face the gym champion in an ultimate showdown.',
      enemyCount: 1, // Just the boss
      difficultyMultiplier: 2.5,
      hasBoss: true,
    ),
  ];

  // Get a specific level
  static Level getLevel(int levelNumber) {
    if (levelNumber < 1 || levelNumber > _levels.length) {
      throw ArgumentError('Level $levelNumber does not exist');
    }
    return _levels[levelNumber - 1];
  }

  // Get all available levels
  static List<Level> getAllLevels() {
    return List.from(_levels);
  }

  // Get the total number of levels
  static int get levelCount => _levels.length;

  // Generate enemies for a given level
  static List<Enemy> generateEnemiesForLevel(
    Level level,
    EnemyFactory enemyFactory,
  ) {
    List<Enemy> enemies = [];

    if (level.hasBoss) {
      // Generate a boss for this level
      enemies.add(
        enemyFactory.createBoss(level.levelNumber, level.difficultyMultiplier),
      );
    } else {
      // Generate regular enemies
      for (int i = 0; i < level.enemyCount; i++) {
        enemies.add(
          enemyFactory.createEnemy(
            level.levelNumber,
            level.difficultyMultiplier,
          ),
        );
      }
    }

    return enemies;
  }
}
