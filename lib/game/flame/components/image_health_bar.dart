import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'; // For debugPrint

// Fix the HasGameReference generic type
class ImageHealthBarComponent extends PositionComponent with HasGameReference<FlameGame> {
  int currentHealth;
  int maxHealth;
  final double barWidth; // Desired width for the health bar

  final List<Sprite> _healthSprites = [];
  late SpriteComponent _displaySprite;

  ImageHealthBarComponent({
    required this.currentHealth,
    required this.maxHealth,
    required this.barWidth,
    super.position,
    super.anchor = Anchor.topLeft,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Load the spritesheet with the correct path
      final image = await game.images.load('ui/hp_bar/hp_bar_spritesheet.png');
      
      // Use the dimensions from the JSON file
      const frameWidth = 3540.0;
      const frameHeight = 385.0;
      
      // Create sprites for each frame (9 frames in the spritesheet)
      for (int i = 0; i < 9; i++) {
        _healthSprites.add(
          Sprite(
            image,
            srcPosition: Vector2(i * frameWidth, 0),
            srcSize: Vector2(frameWidth, frameHeight),
          )
        );
      }

      if (_healthSprites.isNotEmpty) {
        // Calculate aspect ratio from the first sprite to maintain proportions
        final aspectRatio = frameHeight / frameWidth;
        final barHeight = barWidth * aspectRatio;

        // Create the sprite component that displays the health bar
        _displaySprite = SpriteComponent(
          sprite: _getSpriteForHealth(),
          size: Vector2(barWidth, barHeight),
          anchor: Anchor.topLeft,
        );
        add(_displaySprite);
        size = _displaySprite.size; // Set component size
      } else {
        debugPrint('Error: Failed to load health bar sprites');
      }
    } catch (e) {
      debugPrint('Error loading health bar sprites: $e');
    }
    
    // Initialize with current health values
    updateHealth(currentHealth, maxHealth);
  }

  void updateHealth(int current, int max) {
    currentHealth = current.clamp(0, max); // Ensure health is within bounds
    maxHealth = max;

    if (_healthSprites.isNotEmpty && _displaySprite.isMounted) {
      _displaySprite.sprite = _getSpriteForHealth();
    }
  }

  Sprite _getSpriteForHealth() {
    if (maxHealth <= 0 || _healthSprites.isEmpty) {
      return _healthSprites.last; // Return empty bar sprite
    }
    final percentage = (currentHealth / maxHealth).clamp(0.0, 1.0);
    // Calculate index: 0 is full, 8 is empty
    final index = (8 - (percentage * 8)).round().clamp(0, 8);
    return _healthSprites[index];
  }
}
