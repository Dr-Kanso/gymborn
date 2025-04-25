import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../gym_game.dart';
import 'player.dart';

class Enemy extends SpriteComponent
    with HasGameRef<GymGame>, CollisionCallbacks {
  // Enemy properties
  double speed = 80;
  double health = 50;
  double damage = 5;

  // Movement
  Vector2 movementDirection = Vector2.zero();
  bool isActive = true;

  // Target tracking
  late Player _player;
  final double detectionRadius;
  final double attackRadius;

  Enemy({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    this.detectionRadius = 200,
    this.attackRadius = 30,
  }) : super(
         sprite: sprite,
         position: position,
         size: size,
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add hitbox for collisions
    add(CircleHitbox(radius: min(size.x, size.y) / 2));

    // Get reference to player (assuming it's loaded already)
    _player = gameRef.children.whereType<Player>().first;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;

    // Calculate distance to player
    final distanceToPlayer = position.distanceTo(_player.position);

    // Chase player when in detection radius
    if (distanceToPlayer < detectionRadius) {
      // Calculate direction to player
      movementDirection = (_player.position - position).normalized();
      position += movementDirection * speed * dt;

      // Attack player when in range
      if (distanceToPlayer < attackRadius) {
        // Attack logic
        attackPlayer();
      }
    } else {
      movementDirection = Vector2.zero();
    }

    // Flip based on movement direction
    if (movementDirection.x < 0 && !isFlippedHorizontally) {
      flipHorizontally();
    } else if (movementDirection.x > 0 && isFlippedHorizontally) {
      flipHorizontally(); // Unflip if moving right and currently flipped
    }
  }

  void attackPlayer() {
    // Attack cooldown logic would go here
    // Damage player
    // Play attack animation, etc.
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      die();
    } else {
      // Flash red or show damage effect
    }
  }

  void die() {
    isActive = false;
    // Add death animation
    gameRef.remove(this);

    // Award points/experience
    gameRef.gameScore += 10;
  }
}
