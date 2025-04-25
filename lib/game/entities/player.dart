import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../providers/stats_provider.dart';
import '../gym_game.dart';

class Player extends SpriteAnimationComponent with HasGameReference<GymGame> {
  final StatsProvider statsProvider;

  // Player stats
  late double speed;
  late double damage;
  late double health;
  late double maxHealth;

  // Movement variables
  Vector2 movementDirection = Vector2.zero();
  bool isMoving = false;
  bool isFacingLeft = false;

  // Animations
  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation attackAnimation;
  bool isAttacking = false;

  Player({required this.statsProvider})
    : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize stats based on player stats
    final stats = statsProvider.stats;
    if (stats != null) {
      speed = 150 + (stats.strength * 2) + (stats.endurance * 3);
      damage = 10 + (stats.strength * 1.5);
      maxHealth = 100 + (stats.endurance * 10) + (stats.recovery * 5);
      health = maxHealth;
    } else {
      // Default values if stats are not loaded
      speed = 200;
      damage = 10;
      maxHealth = 100;
      health = maxHealth;
    }

    // Load sprite animations
    try {
      // Try to load sprite sheet if available
      final spriteSheet = await game.images.load('characters/women_idle.png');
      final spriteSize = Vector2(32, 32); // Adjust based on your sprite sheet

      // Create a sprite sheet
      final sheet = SpriteSheet(image: spriteSheet, srcSize: spriteSize);

      // Define animations
      // Note: Indices should be adjusted based on your actual sprite sheet layout
      idleAnimation = sheet.createAnimation(
        row: 0,
        stepTime: 0.2,
        to: 4,
      ); // Loop is true by default
      runAnimation = sheet.createAnimation(
        row: 1,
        stepTime: 0.1,
        to: 6,
      ); // Loop is true by default
      attackAnimation = sheet.createAnimation(
        row: 2,
        stepTime: 0.05,
        to: 4,
        loop: false,
      ); // Attack animation should not loop

      // Set initial animation
      animation = idleAnimation;
    } catch (e) {
      // Fallback to a simple colored rectangle if animation loading fails
      debugPrint('Failed to load player animations: $e');

      // Create a colored rectangle as fallback
      final fallbackPaint = Paint()..color = Colors.blue;
      add(
        RectangleComponent(
          size: size,
          paint: fallbackPaint,
          anchor: Anchor.center,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (movementDirection != Vector2.zero()) {
      position += movementDirection.normalized() * speed * dt;

      // Keep player within screen bounds
      final gameSize = game.size;
      position.x = position.x.clamp(width / 2, gameSize.x - width / 2);
      position.y = position.y.clamp(height / 2, gameSize.y - height / 2);

      // Update animation state if not attacking
      if (animation != runAnimation && !isAttacking) {
        animation = runAnimation;
      }

      // Flip sprite based on movement direction
      if (movementDirection.x < 0) {
        if (!isFlippedHorizontally) {
          isFacingLeft = true; // Keep track if needed elsewhere
          flipHorizontally();
        }
      } else if (movementDirection.x > 0) {
        if (isFlippedHorizontally) {
          isFacingLeft = false; // Keep track if needed elsewhere
          flipHorizontally(); // Call again to unflip
        }
      }
    } else if (isMoving == false &&
        animation != idleAnimation &&
        !isAttacking) {
      animation = idleAnimation;
    }

    // Check if attack animation is complete
    if (isAttacking &&
        animation == attackAnimation &&
        animationTicker!.done()) {
      isAttacking = false;
      animation = idleAnimation; // Revert to idle animation after attack
      // No need to reset idleAnimation here unless it's also non-looping and needs restarting
    }
  }

  void move(Vector2 direction) {
    movementDirection = direction;
    isMoving = direction != Vector2.zero();
  }

  void attack() {
    // Play attack animation
    isAttacking = true;
    animation = attackAnimation;
    animationTicker
        ?.reset(); // Reset the animation ticker to start from the beginning

    // Attack logic would be implemented here
    // e.g., damage enemies in range, etc.
  }
}
