import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/stats_provider.dart';
import 'entities/player.dart';
import 'world/dungeon_world.dart';

class GymGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents, TapDetector {
  final StatsProvider statsProvider;

  // Game entities
  late Player player;
  late DungeonWorld dungeonWorld;

  // Game state
  double gameScore = 0;
  int enemiesDefeated = 0;
  bool gameOver = false;

  GymGame({required this.statsProvider});

  @override
  Future<void> onLoad() async {
    // Set camera viewport
    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 600));

    // Load background
    try {
      final background = await loadSprite('dungeons/background.png');
      add(
        SpriteComponent(sprite: background, size: Vector2(size.x, size.y))
          ..priority = -1,
      );
    } catch (e) {
      debugPrint('Failed to load background: $e');
      // Fallback to a colored background
      add(
        RectangleComponent(
          size: Vector2(size.x, size.y),
          paint: Paint()..color = const Color(0xFF333333),
        )..priority = -1,
      );
    }

    // Add player
    player = Player(statsProvider: statsProvider);
    player.position = Vector2(size.x / 2, size.y / 2);
    add(player);

    // Add dungeon world (which will handle enemies and obstacles)
    dungeonWorld = DungeonWorld(statsProvider: statsProvider);
    add(dungeonWorld);

    // Add UI components
    add(
      TextComponent(
        text: 'Score: 0',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        position: Vector2(20, 20),
        anchor: Anchor.topLeft,
      )..priority = 10,
    );

    // Start tracking score
    add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: () {
          gameScore += 1;
          updateScore();
        },
      ),
    );
  }

  void updateScore() {
    final scoreComponent = children.whereType<TextComponent>().firstWhere(
      (component) => component.text.startsWith('Score:'),
      orElse: () => TextComponent(),
    );

    // Remove null check as text can't be null
    scoreComponent.text = 'Score: ${gameScore.toInt()}';
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update camera to follow player
    camera.moveTo(player.position);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;

    Vector2 direction = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      direction.x -= 1;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      direction.x += 1;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      direction.y -= 1;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      direction.y += 1;
    }

    player.move(direction);

    // Handle attack with space bar
    if (keysPressed.contains(LogicalKeyboardKey.space) && isKeyDown) {
      player.attack();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    // Tap to move or attack depending on context
    final worldPosition = camera.viewfinder.globalToLocal(
      info.eventPosition.global,
    );

    // Simple tap to move
    player.move((worldPosition - player.position).normalized());

    // Schedule stopping after reaching tap position
    Future.delayed(const Duration(milliseconds: 500), () {
      player.move(Vector2.zero());
    });
  }

  void endGame() {
    gameOver = true;
    pauseEngine();

    // Game over logic would be implemented here
  }
}
