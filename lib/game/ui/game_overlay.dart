import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:gymborn_app/game/engine/gym_game.dart';
import '../flame/components/image_health_bar.dart'; // Import the new component

class GameOverlay extends PositionComponent with HasGameReference<GymGame> {
  late final SpriteButtonComponent nextLevelButton;

  // UI elements
  final TextPaint _scorePaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
  );

  // Game stats to display
  int _score = 0;

  // Add the new health bar component
  late ImageHealthBarComponent _healthBarComponent;
  static const double _healthBarWidth = 200.0; // Changed from 150.0

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render score at top right
    _scorePaint.render(
      canvas,
      'Score: $_score',
      Vector2(game.size.x - 20, 20),
      anchor: Anchor.topRight,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Mark overlay as ignoring taps so they pass through to the game layer
    // This ensures taps reach the game for attack functionality
    debugMode = true; // Shows component boundaries for debugging

    // Instantiate and add the new health bar component
    _healthBarComponent = ImageHealthBarComponent(
      currentHealth: 100, // Initial value (will be updated)
      maxHealth: 100,   // Initial value (will be updated)
      barWidth: _healthBarWidth,
      position: Vector2(20, 20), // Position top-left
    );
    add(_healthBarComponent);

    // Add Next Level button
    try {
      // The button image should be placed in assets/images/ui/next_level_button.png
      final buttonImage = await game.images.load('ui/next_level_button.png');
      
      // Create next level button at the top right of the screen
      nextLevelButton = SpriteButtonComponent(
        button: Sprite(buttonImage),
        buttonDown: Sprite(buttonImage), // Same image for pressed state
        position: Vector2(game.size.x - 100, 80), // Positioned below the score
        size: Vector2(150, 50), // Adjust size as needed
        anchor: Anchor.center,
        onPressed: () {
          // Call the nextLevel method on the game
          game.nextLevel();
        },
      );
      
      // Add a text component to the button
      final buttonText = TextComponent(
        text: 'NEXT LEVEL',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(75, 25), // Center of the button
      );
      
      nextLevelButton.add(buttonText);
      add(nextLevelButton);
      
    } catch (e) {
      debugPrint('Error loading Next Level button: $e');
    }
  }

  @override
  void onMount() {
    super.onMount();

    // Add a slide button only
    ButtonComponent slideButton = ButtonComponent(
      button: CircleComponent(
        radius: 32, 
        paint: Paint()..color = Colors.blue.withAlpha((0.5 * 255).toInt()),
      ),
      position: Vector2(game.size.x - 80, game.size.y - 80),
      onPressed: () {
        game.player.slide();
      },
    )..anchor = Anchor.center;

    add(slideButton);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Reposition next level button
    if (nextLevelButton.isMounted) {
      nextLevelButton.position = Vector2(size.x - 100, 80);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Only return true for points inside UI elements, let all other taps through
    // Check if the point is within any active UI components
    
    // If we have a button, only handle taps on the button
    if (nextLevelButton.isMounted) {
      final buttonRect = nextLevelButton.toRect();
      if (buttonRect.contains(Offset(point.x, point.y))) {
        return true; // Handle the tap for UI elements
      }
    }
    
    // Let taps pass through to trigger attacks
    return false;
  }

  void updateScore(int score) {
    _score = score;
  }

  // Modify updateHealth to update the new component
  void updateHealth(double health, double maxHealth) {
    if (_healthBarComponent.isMounted) {
       _healthBarComponent.updateHealth(health.toInt(), maxHealth.toInt());
    }
  }
}
