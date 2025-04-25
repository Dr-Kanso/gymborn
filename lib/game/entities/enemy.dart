import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../gym_game.dart';
import 'player.dart';

class Enemy extends SpriteAnimationComponent
    with HasGameRef<GymGame>, CollisionCallbacks {
  // Enemy properties
  double speed = 80;
  double health = 50;
  double damage = 5;

  // Movement
  Vector2 movementDirection = Vector2.zero();
  bool isActive = true;

  // Target tracking
  Player? _player;
  final double detectionRadius;
  final double attackRadius;
  
  // Animation states
  late final SpriteAnimation idleAnimation;
  final String spritePath;
  
  // Screen boundary constraints
  double minX = 0;
  double maxX = 0;
  double minY = 0;
  double maxY = 0;
  bool _boundariesSet = false;

  Enemy({
    required this.spritePath,
    required Vector2 position,
    required Vector2 size,
    this.detectionRadius = 200,
    this.attackRadius = 30,
  }) : super(
         position: position,
         size: size,
         anchor: Anchor.center,
       );
       
  // Set movement boundaries to keep enemy on screen
  void setBoundaries(double minX, double maxX, double minY, double maxY) {
    this.minX = minX;
    this.maxX = maxX;
    this.minY = minY;
    this.maxY = maxY;
    _boundariesSet = true;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load sprite sheet from json file
    final spriteSheet = await gameRef.loadSpriteSheet();
    
    // Create idle animation
    idleAnimation = spriteSheet.createAnimation(
      row: 0, 
      stepTime: 0.1,
      to: 17, // Number of frames in the idle animation
    );
    
    // Set current animation
    animation = idleAnimation;

    // Add hitbox for collisions
    add(CircleHitbox(radius: min(size.x, size.y) / 2));

    // Try to find player, but don't fail if not found yet
    _findPlayer();
  }
  
  void _findPlayer() {
    final players = gameRef.children.whereType<Player>();
    if (players.isNotEmpty) {
      _player = players.first;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;
    
    // Try to get player reference if we don't have it yet
    if (_player == null) {
      _findPlayer();
      return; // Skip this update if player still not found
    }

    // Calculate distance to player
    final distanceToPlayer = position.distanceTo(_player!.position);

    // Chase player when in detection radius
    if (distanceToPlayer < detectionRadius) {
      // Calculate direction to player
      movementDirection = (_player!.position - position).normalized();
      
      // Calculate new position
      Vector2 newPosition = position + movementDirection * speed * dt;
      
      // Enforce boundaries if they're set
      if (_boundariesSet) {
        newPosition.x = newPosition.x.clamp(minX, maxX);
        newPosition.y = newPosition.y.clamp(minY, maxY);
      }
      
      // Apply the new position
      position = newPosition;

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
    // TODO: Play attack animation when it's available
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
