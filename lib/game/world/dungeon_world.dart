import 'dart:math';

import 'package:flame/components.dart';

import '../../providers/stats_provider.dart';
import '../entities/enemy.dart';
import '../gym_game.dart';

class DungeonWorld extends Component with HasGameRef<GymGame> {
  final StatsProvider statsProvider;
  final Random _random = Random();

  DungeonWorld({required this.statsProvider});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Generate the dungeon based on stats
    await _generateDungeon();
  }

  Future<void> _generateDungeon() async {
    // Load enemy sprite
    final enemySprite = await gameRef.loadSprite('dungeons/enemy.png');
    final spiderSprite = await gameRef.loadSprite('dungeons/enemy.png');

    // Generate enemies based on player stats
    final stats = statsProvider.stats;
    final enemyCount =
        5 + (stats?.totalLevel ?? 0) ~/ 3; // More enemies as player levels up

    // Spawn enemies
    for (int i = 0; i < enemyCount; i++) {
      // Random position within game bounds
      final x = _random.nextDouble() * gameRef.size.x;
      final y = _random.nextDouble() * gameRef.size.y;

      // Randomly choose enemy type
      final enemyType = _random.nextBool() ? enemySprite : spiderSprite;

      // Create enemy with properties scaled with player stats
      final enemy = Enemy(
        sprite: enemyType,
        position: Vector2(x, y),
        size: Vector2(48, 48),
        detectionRadius: 150 + (_random.nextDouble() * 100),
      );

      gameRef.add(enemy);
    }

    // Add walls, obstacles, etc.
    _addObstacles();
  }

  void _addObstacles() {
    // Add walls and obstacles
    // This would be expanded with more detailed dungeon generation
  }
}
