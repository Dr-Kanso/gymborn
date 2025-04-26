import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'entities/enemy.dart';
import 'enemy_controller.dart';
import '../screens/dungeon_screen.dart'; // Import for PlayableArea

class GameWorld extends FlameGame with TapDetector, KeyboardEvents {
  late Enemy enemy;
  late EnemyController enemyController;
  
  // Add playable area to constraint movement
  final PlayableArea? playableArea;
  
  GameWorld({this.playableArea});
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create enemy positioned in center of playable area
    final screenSize = size;
    final enemySize = Vector2(150, 150); // Scaled down from the 900x900 sprites
    
    // Calculate playable area center
    double centerX = screenSize.x / 2;
    double centerY = screenSize.y / 2;
    
    enemy = Enemy(
      position: Vector2(centerX, centerY),
      size: enemySize,
    );
    
    enemyController = EnemyController(enemy: enemy);
    
    // Pass playable area boundaries to enemy
    if (playableArea != null) {
      final minX = playableArea!.leftMargin;
      final maxX = screenSize.x - playableArea!.rightMargin;
      final minY = playableArea!.topMargin;
      final maxY = screenSize.y - playableArea!.bottomMargin;
      
      enemy.setBoundaries(minX, maxX, minY, maxY);
    }
    
    // Add components to game
    add(enemy);
    add(enemyController);
    
    // Add instructions
    add(
      TextComponent(
        text: 'Tap to damage enemy, Space to attack, R to run',
        position: Vector2(20, 20),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
  
  @override
  void onTap() {
    // Damage enemy on tap
    enemyController.hitEnemy(20);
  }
  
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event, 
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        enemy.attack();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
        enemy.startRunning();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // Update boundaries when game is resized
    if (playableArea != null) {
      final minX = playableArea!.leftMargin;
      final maxX = size.x - playableArea!.rightMargin;
      final minY = playableArea!.topMargin;
      final maxY = size.y - playableArea!.bottomMargin;
      
      enemy.setBoundaries(minX, maxX, minY, maxY);
    }
  }
}
