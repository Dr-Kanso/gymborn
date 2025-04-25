import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'entities/enemy.dart';
import 'enemy_controller.dart';

class GameWorld extends FlameGame with TapDetector, KeyboardEvents {
  late Enemy enemy;
  late EnemyController enemyController;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create enemy positioned in center of screen
    final screenSize = size;
    final enemySize = Vector2(150, 150); // Scaled down from the 900x900 sprites
    
    enemy = Enemy(
      position: Vector2(screenSize.x / 2, screenSize.y / 2),
      size: enemySize,
    );
    
    enemyController = EnemyController(enemy: enemy);
    
    // Add components to game
    add(enemy);
    add(enemyController);
    
    // Add instructions
    add(
      TextComponent(
        text: 'Tap to damage enemy, Space to attack, R to run',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        position: Vector2(20, 20),
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
}
