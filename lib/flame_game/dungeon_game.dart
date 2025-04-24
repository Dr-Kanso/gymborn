import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../themes/theme.dart';

// This is a placeholder implementation that will be expanded later
// with actual game mechanics using the Flame engine

class DungeonGame extends FlameGame with TapDetector, HasCollisionDetection {
  late final String dungeonType;
  late final String dungeonName;
  late final Color dungeonColor;
  late final int dungeonLevel;

  late final TextComponent titleComponent;
  late final SpriteComponent playerComponent;
  late final SpriteComponent enemyComponent;

  bool gameOver = false;
  bool victory = false;
  int playerHealth = 100;
  int enemyHealth = 100;

  DungeonGame({
    required this.dungeonType,
    required this.dungeonName,
    required this.dungeonColor,
    required this.dungeonLevel,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set up background
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = dungeonColor.withOpacity(0.2),
    );
    add(background);

    // Title text
    titleComponent = TextComponent(
      text: dungeonName,
      textRenderer: TextPaint(
        style: TextStyle(
          color: dungeonColor,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    titleComponent.position = Vector2(
      size.x / 2 - titleComponent.width / 2,
      50,
    );
    add(titleComponent);

    // Simple placeholder for player and enemy
    playerComponent =
        RectangleComponent(
              size: Vector2(50, 80),
              position: Vector2(size.x / 4, size.y / 2),
              paint: Paint()..color = kPrimaryColor,
            )
            as SpriteComponent;
    add(playerComponent);

    enemyComponent =
        RectangleComponent(
              size: Vector2(60, 90),
              position: Vector2(3 * size.x / 4, size.y / 2),
              paint: Paint()..color = Colors.red,
            )
            as SpriteComponent;
    add(enemyComponent);

    // Health bars
    _addHealthBars();

    // Instructions
    final instructionsComponent = TextComponent(
      text: 'Tap to attack',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );
    instructionsComponent.position = Vector2(
      size.x / 2 - instructionsComponent.width / 2,
      size.y - 100,
    );
    add(instructionsComponent);
  }

  void _addHealthBars() {
    // Player health bar
    final playerHealthBar = RectangleComponent(
      size: Vector2(100, 10),
      position: Vector2(size.x / 4 - 25, size.y / 2 - 20),
      paint: Paint()..color = Colors.green,
    );
    add(playerHealthBar);

    // Enemy health bar
    final enemyHealthBar = RectangleComponent(
      size: Vector2(100, 10),
      position: Vector2(3 * size.x / 4 - 25, size.y / 2 - 20),
      paint: Paint()..color = Colors.green,
    );
    add(enemyHealthBar);
  }

  @override
  void onTap() {
    if (gameOver) return;

    // Simple attack mechanic
    enemyHealth -= 10;
    if (enemyHealth <= 0) {
      enemyHealth = 0;
      gameOver = true;
      victory = true;
      _showGameOverText();
    }

    // Enemy counter-attack
    Future.delayed(const Duration(milliseconds: 500), () {
      if (gameOver) return;

      playerHealth -= 8;
      if (playerHealth <= 0) {
        playerHealth = 0;
        gameOver = true;
        victory = false;
        _showGameOverText();
      }
    });
  }

  void _showGameOverText() {
    final gameOverComponent = TextComponent(
      text: victory ? 'Victory!' : 'Defeat!',
      textRenderer: TextPaint(
        style: TextStyle(
          color: victory ? Colors.green : Colors.red,
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    gameOverComponent.position = Vector2(
      size.x / 2 - gameOverComponent.width / 2,
      size.y / 2 - gameOverComponent.height / 2,
    );
    add(gameOverComponent);
  }
}

// Widget that wraps the Flame game for Flutter integration
class DungeonGameWidget extends StatelessWidget {
  final String dungeonType;
  final String dungeonName;
  final Color dungeonColor;
  final int dungeonLevel;
  final VoidCallback onGameOver;

  const DungeonGameWidget({
    super.key,
    required this.dungeonType,
    required this.dungeonName,
    required this.dungeonColor,
    required this.dungeonLevel,
    required this.onGameOver,
  });

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: DungeonGame(
        dungeonType: dungeonType,
        dungeonName: dungeonName,
        dungeonColor: dungeonColor,
        dungeonLevel: dungeonLevel,
      ),
      loadingBuilder:
          (context) => const Center(child: CircularProgressIndicator()),
      errorBuilder:
          (context, error) => Center(
            child: Text(
              'An error occurred: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
    );
  }
}
