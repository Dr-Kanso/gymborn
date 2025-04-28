import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../providers/stats_provider.dart';
import '../ui/dungeon_screen.dart'; // Import for PlayableArea
import '../entities/player.dart';
import '../world/dungeon_world.dart';
import '../ui/game_overlay.dart';

class GymGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents, TapDetector {
  final StatsProvider statsProvider;
  final PlayableArea? playableArea; // Added PlayableArea parameter

  // Game entities
  late Player player;
  late DungeonWorld dungeonWorld;

  // Track initialization state
  bool _isPlayerInitialized = false;

  // Game state
  double gameScore = 0;
  int enemiesDefeated = 0;
  bool gameOver = false;
  int currentLevel = 1; // Track current level

  GymGame({required this.statsProvider, this.playableArea}); // Updated constructor

  @override
  Future<void> onLoad() async {
    await super.onLoad();

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

    // Add overlay for UI
    add(GameOverlay());

    // Add player
    player = Player(statsProvider: statsProvider);
    
    // Position player within the blue box region
    if (playableArea != null) {
      // Calculate the blue box region
      double leftEdge = playableArea!.leftMargin;
      double topEdge = playableArea!.topMargin;
      double playableWidth = size.x - playableArea!.leftMargin - playableArea!.rightMargin;
      double playableHeight = size.y - playableArea!.topMargin - playableArea!.bottomMargin;
      
      // Position the player
      double blueBoxX = leftEdge + (playableWidth * 0.15); 
      double blueBoxY = topEdge + (playableHeight * 0.25);
      
      player.position = Vector2(blueBoxX, blueBoxY);
    } else {
      // Fallback to center if no playable area defined
      player.position = Vector2(size.x / 2, size.y / 2);
    }

    add(player);
    _isPlayerInitialized = true;

    // Add dungeon world
    add(DungeonWorld(
      statsProvider: statsProvider,
      playableArea: playableArea,
    ));

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

    // Enable overlays for controls
    overlays.add('touchControls');

    // Make sure tap events are properly detected
    debugPrint('GymGame loaded - tap detection should be active');
  }

  void updateScore() {
    final scoreComponent = children.whereType<TextComponent>().firstWhere(
      (component) => component.text.startsWith('Score:'),
      orElse: () => TextComponent(),
    );

    scoreComponent.text = 'Score: ${gameScore.toInt()}';
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isPlayerInitialized && !gameOver) {
      camera.moveTo(player.position);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!_isPlayerInitialized || gameOver) {
      return KeyEventResult.handled;
    }

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

    // Handle sliding with Shift key
    if (isKeyDown && event.logicalKey == LogicalKeyboardKey.shift) {
      player.slide();
      return KeyEventResult.handled;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onTapDown(TapDownInfo info) {
    // Re-enable the parent call so Flame processes the event.
    super.onTapDown(info);
    debugPrint('TapDown: ${info.eventPosition.global}');
    
    // Skip tap handling if player not initialized yet or game is over
    if (!_isPlayerInitialized || gameOver) {
      debugPrint('Player not initialized or game over - ignoring tap');
      return;
    }
    
    // Directly trigger attack with priority
    debugPrint('Triggering player attack from tap');
    player.attack();
  }
  
  // Override onTap to ensure any tap event will trigger the attack
  @override
  void onTap() {
    if (_isPlayerInitialized && !gameOver) {
      debugPrint('onTap called - triggering attack');
      player.attack();
    }
  }

  // Disable tap up handling that might interfere
  @override
  void onTapUp(TapUpInfo info) {
    // Intentionally empty to prevent conflicts
  }

  void endGame() {
    gameOver = true;
    pauseEngine();
    // Game over logic would be implemented here
  }

  Future<SpriteSheet> loadSpriteSheet() async {
    final image = await images.load('dungeons/enemy.png');
    return SpriteSheet(
      image: image,
      srcSize: Vector2(900, 900),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Update camera viewport to match the new screen size
    camera.viewport = FixedResolutionViewport(resolution: size);

    // Update world boundaries for the dungeon
    final dungeonWorlds = children.whereType<DungeonWorld>();
    if (dungeonWorlds.isNotEmpty) {
      dungeonWorlds.first.resize(size);
    }

    // Reposition UI elements
    _repositionUI(size);
  }

  void _repositionUI(Vector2 gameSize) {
    // Find score text component
    final scoreComponents = children.whereType<TextComponent>().where(
      (component) => component.text.startsWith('Score:'),
    );

    if (scoreComponents.isNotEmpty) {
      final scoreComponent = scoreComponents.first;
      scoreComponent.position = Vector2(20, 20); // Keep in top-left corner
    }
  }

  // Add next level functionality
  void nextLevel() {
    // Increment level
    currentLevel++;
    
    // Reset or modify game state for next level
    enemiesDefeated = 0;
    
    // Increase difficulty based on level
    final dungeonWorlds = children.whereType<DungeonWorld>();
    if (dungeonWorlds.isNotEmpty) {
      dungeonWorlds.first.setLevel(currentLevel);
    }
    
    // Award bonus points for completing a level
    gameScore += 100 * currentLevel;
    updateScore();
    
    // Optional: Display level transition overlay
    overlays.add('levelTransition');
    
    // Trigger level change event for any listeners
    onLevelChange?.call(currentLevel);
  }

  // Optional level change callback
  Function(int)? onLevelChange;
}
