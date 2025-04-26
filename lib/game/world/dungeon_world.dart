import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../providers/stats_provider.dart';
import '../entities/enemy.dart';
import '../gym_game.dart';
import '../../screens/dungeon_screen.dart'; // Import for PlayableArea

class DungeonWorld extends Component with HasGameReference<GymGame> {
  final StatsProvider statsProvider;
  final Random _random = Random();
  
  // Store world boundaries to enforce limits
  late Vector2 worldSize;
  final PlayableArea? playableArea;
  
  // Define actual playable boundaries
  late double _minX;
  late double _maxX;
  late double _minY;
  late double _maxY;

  DungeonWorld({required this.statsProvider, this.playableArea});

  @override
  Future<void> onLoad() async {
    try {
      // Force landscape orientation for dungeons
      await _setLandscapeOrientation();
      
      await super.onLoad();
      
      // Set world size based on game viewport
      worldSize = game.size.clone();
      
      // Calculate playable boundaries
      _setPlayableBoundaries();
      
      // Generate the dungeon based on stats
      await _generateDungeon();
    } catch (e) {
      debugPrint('Error loading dungeon world: $e');
      // Handle error state appropriately
    }
  }
  
  void _setPlayableBoundaries() {
    if (playableArea != null) {
      _minX = playableArea!.leftMargin;
      _maxX = worldSize.x - playableArea!.rightMargin;
      _minY = playableArea!.topMargin;
      _maxY = worldSize.y - playableArea!.bottomMargin;
    } else {
      // Default fallback to 50.0 padding if no playable area provided
      const double defaultPadding = 50.0;
      _minX = defaultPadding;
      _maxX = worldSize.x - defaultPadding;
      _minY = defaultPadding;
      _maxY = worldSize.y - defaultPadding;
    }
  }

  Future<void> _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _generateDungeon() async {
    // Generate enemies based on player stats
    final stats = statsProvider.stats;
    final enemyCount =
        5 + (stats?.totalLevel ?? 0) ~/ 3; // More enemies as player levels up

    // Adjust enemy distribution for horizontal layout
    // Distribute enemies within the playable area
    double horizontalSpacing = (_maxX - _minX) / (enemyCount + 1);

    // Spawn enemies
    for (int i = 0; i < enemyCount; i++) {
      // Position within playable area only
      final x = _minX + (i * horizontalSpacing) + (_random.nextDouble() * horizontalSpacing * 0.5);
      final y = _minY + _random.nextDouble() * (_maxY - _minY);

      // Create enemy
      final enemy = Enemy(
        position: Vector2(x, y),
        size: Vector2(48, 48),
      );
      
      // Set detection radius (can be accessed from enemy.detectionRadius now)
      enemy.detectionRadius = 150 + (_random.nextDouble() * 100);

      // Pass playable area boundaries to enemy
      enemy.setBoundaries(_minX, _maxX, _minY, _maxY);
      
      game.add(enemy);
    }

    // Add walls, obstacles, etc.
    _addObstacles();
  }

  // Called when game window is resized
  void resize(Vector2 newSize) {
    worldSize = newSize.clone();
    
    // Recalculate playable boundaries
    _setPlayableBoundaries();
    
    // Update boundaries for all existing enemies
    for (final enemy in game.children.whereType<Enemy>()) {
      enemy.setBoundaries(_minX, _maxX, _minY, _maxY);
    }
  }

  @override
  void onRemove() {
    // Reset orientation when leaving the dungeon
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.onRemove();
  }

  void _addObstacles() {
    // Add walls and obstacles
    // This would be expanded with more detailed dungeon generation
  }
}
