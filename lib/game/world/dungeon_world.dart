import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../providers/stats_provider.dart';
import '../entities/enemy.dart';
import '../gym_game.dart';

class DungeonWorld extends Component with HasGameReference<GymGame> {
  final StatsProvider statsProvider;
  final Random _random = Random();
  
  // Store world boundaries to enforce limits
  late Vector2 worldSize;
  static const double worldPadding = 50.0;

  DungeonWorld({required this.statsProvider});

  @override
  Future<void> onLoad() async {
    try {
      await super.onLoad();
      
      // Set world size based on game viewport with padding
      worldSize = game.size.clone();
      
      // Generate the dungeon based on stats
      await _generateDungeon();
    } catch (e) {
      debugPrint('Error loading dungeon world: $e');
      // Handle error state appropriately
    }
  }

  Future<void> _generateDungeon() async {
    // Generate enemies based on player stats
    final stats = statsProvider.stats;
    final enemyCount =
        5 + (stats?.totalLevel ?? 0) ~/ 3; // More enemies as player levels up

    // Spawn enemies
    for (int i = 0; i < enemyCount; i++) {
      // Random position within game bounds (respecting padding)
      final x = worldPadding + _random.nextDouble() * (worldSize.x - 2 * worldPadding);
      final y = worldPadding + _random.nextDouble() * (worldSize.y - 2 * worldPadding);

      // Create enemy
      final enemy = Enemy(
        position: Vector2(x, y),
        size: Vector2(48, 48),
      );
      
      // Set detection radius (can be accessed from enemy.detectionRadius now)
      enemy.detectionRadius = 150 + (_random.nextDouble() * 100);

      // Pass world boundaries to enemy for movement constraints
      enemy.setBoundaries(worldPadding, worldSize.x - worldPadding, 
                         worldPadding, worldSize.y - worldPadding);
      
      game.add(enemy);
    }

    // Add walls, obstacles, etc.
    _addObstacles();
  }

  // Called when game window is resized
  void resize(Vector2 newSize) {
    worldSize = newSize.clone();
    
    // Update boundaries for all existing enemies
    for (final enemy in game.children.whereType<Enemy>()) {
      enemy.setBoundaries(worldPadding, worldSize.x - worldPadding,
                         worldPadding, worldSize.y - worldPadding);
    }
  }

  void _addObstacles() {
    // Add walls and obstacles
    // This would be expanded with more detailed dungeon generation
  }
}
