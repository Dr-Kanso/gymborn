// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:gymborn_app/game/entities/enemy.dart';

import '../../providers/stats_provider.dart';
import '../engine/gym_game.dart';

enum PlayerState {
  idle,
  running,
  attacking,
  sliding,
}

class Player extends SpriteAnimationComponent with HasGameReference<GymGame>, CollisionCallbacks {
  // Player properties
  final StatsProvider statsProvider;
  double speed = 150;
  double health = 100;
  double attackPower = 10;
  
  // Movement
  Vector2 movementDirection = Vector2.zero();
  
  // Animations - replace individual animations with a map
  late Map<PlayerState, SpriteAnimation> animations;
  PlayerState currentState = PlayerState.idle;
  
  // Track non-looping animations
  final Map<PlayerState, bool> _nonLoopingStates = {
    PlayerState.attacking: true,
    PlayerState.sliding: true,
  };
  
  // State
  bool _isAttacking = false;
  bool _isSliding = false;
  final double _slideSpeed = 300;
  final double _slideDuration = 0.5;
  double _slideTimer = 0;
  bool _isInvulnerable = false;
  
  // Screen boundary constraints
  double minX = 0;
  double maxX = 0;
  double minY = 0;
  double maxY = 0;
  bool _boundariesSet = false;
  
  // Track the attack hitbox to update its position during animation
  RectangleHitbox? _swordHitbox;
  // Track animation frame to position sword hitbox accurately

  Player({
    required this.statsProvider,
    Vector2? position,
    Vector2? size,
  }) : super(
         position: position ?? Vector2.zero(),
         size: size ?? Vector2(128, 128),
         anchor: Anchor.center,
       );
       
  // Set movement boundaries to keep player on screen
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
    
    // Load all animations from JSON files
    await _loadAnimations();
    
    // Set initial animation
    animation = animations[currentState];
    
    // Add hitbox for player body collisions (smaller than the full sprite)
    // Make it Active to detect collisions from enemy attacks
    add(CircleHitbox(radius: min(size.x, size.y) / 3)
      ..position = Vector2(0, size.y * 0.2) // Slightly lower to better match body
      ..collisionType = CollisionType.active); // Make player body hitbox active
  }
  
  Future<void> _loadAnimations() async {
    // Load all sprite sheets
    final idleImage = await game.images.load('characters/women_idle.png');
    final idleSpriteSheet = SpriteSheet(
      image: idleImage,
      srcSize: Vector2(900, 900),
    );
    
    final runningImage = await game.images.load('characters/women_running.png');
    final runningSpriteSheet = SpriteSheet(
      image: runningImage, 
      srcSize: Vector2(900, 900),
    );
    
    final attackImage = await game.images.load('characters/women_slashing.png');
    final attackSpriteSheet = SpriteSheet(
      image: attackImage,
      srcSize: Vector2(900, 900),
    );
    
    final slideImage = await game.images.load('characters/women_sliding.png');
    final slideSpriteSheet = SpriteSheet(
      image: slideImage,
      srcSize: Vector2(900, 900),
    );
    
    // Create animations from sprite sheets and store in map
    animations = {
      PlayerState.idle: idleSpriteSheet.createAnimation(
        row: 0, 
        stepTime: 0.1, 
        to: 17
      ),
      PlayerState.running: runningSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.6, 
        to: 11
      ),
      PlayerState.attacking: attackSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.04, 
        to: 11,
        loop: false,
      ),
      PlayerState.sliding: slideSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1, 
        to: 5,
        loop: false,
      ),
    };
  }
  
  void move(Vector2 direction) {
    movementDirection = direction;
    
    // Update sprite horizontal direction based on movement
    if (direction.x != 0) {
      if ((direction.x < 0 && !isFlippedHorizontally) || 
          (direction.x > 0 && isFlippedHorizontally)) {
        flipHorizontally();
      }
    }
    
    // Update state based on movement
    if (direction.length > 0 && currentState != PlayerState.attacking && 
        currentState != PlayerState.sliding) {
      changeState(PlayerState.running);
    } else if (direction.length == 0 && currentState != PlayerState.attacking && 
              currentState != PlayerState.sliding) {
      changeState(PlayerState.idle);
    }
  }
  
  void attack() {
    if (currentState != PlayerState.attacking && !_isSliding) {
      _isAttacking = true;
      changeState(PlayerState.attacking);
      
      // Create a more precise hitbox for the sword
      final Vector2 swordSize = Vector2(size.x * 0.3, size.y * 0.4);
      
      // Position the hitbox near the player's feet and closer horizontally
      // Restore directional logic and reduce the offset multiplier
      final double swordOffsetX = size.x * 0.8; 
      final double swordOffsetY = size.y * 0.5; // Keep Y offset near feet
      
      _swordHitbox = RectangleHitbox(
        position: Vector2(swordOffsetX, swordOffsetY),
        size: swordSize,
        anchor: Anchor.center,
        collisionType: CollisionType.active,
      )..debugMode = true; // Keep debug mode to visualize hitbox
      
      add(_swordHitbox!);
    }
  }

  void slide() {
    if (currentState != PlayerState.sliding && !_isSliding) {
      _isSliding = true;
      _isInvulnerable = true;
      _slideTimer = 0;
      
      if (movementDirection.length == 0) {
        _isSliding = false;
        _isInvulnerable = false;
        return;
      }
      
      if (movementDirection.length > 1) {
        movementDirection = movementDirection.normalized();
      }
      
      if (movementDirection.x != 0) {
        if ((movementDirection.x < 0 && !isFlippedHorizontally) || 
            (movementDirection.x > 0 && isFlippedHorizontally)) {
          flipHorizontally();
        }
      }
      
      changeState(PlayerState.sliding);
    }
  }
  
  // New method to match enemy.dart pattern
  void changeState(PlayerState newState) {
    if (newState == currentState) return;
    
    currentState = newState;
    animation = animations[newState];
    
    // Set animation to first frame
    if (animation != null) {
      animationTicker?.reset();
    }
  }
  
  // New method to handle animation completion
  void _returnToIdle() {
    _isAttacking = false;
    _isSliding = false;
    
    if (movementDirection.length > 0) {
      changeState(PlayerState.running);
    } else {
      changeState(PlayerState.idle);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle animation completion for non-looping animations
    if (_nonLoopingStates[currentState] == true &&
        animationTicker != null &&
        animationTicker!.isLastFrame &&
        animation != null && 
        !animation!.loop) {
      
      // Special handling for slide state
      if (currentState == PlayerState.sliding) {
        _isSliding = false;
        _isInvulnerable = false;
      }
      
      // Special handling for attack state
      if (currentState == PlayerState.attacking) {
        _isAttacking = false;
        if (_swordHitbox != null && _swordHitbox!.parent != null) {
          _swordHitbox!.removeFromParent();
          _swordHitbox = null;
        }
      }
      
      _returnToIdle();
      return;
    }
    
    if (_isSliding) {
      // Update slide timer
      _slideTimer += dt;
      
      // Move player in sliding direction with increased speed
      Vector2 slideDirection = movementDirection.normalized();
      
      Vector2 newPosition = position + slideDirection * _slideSpeed * dt;
      
      // Enforce boundaries if they're set
      if (_boundariesSet) {
        double xOffset = size.x / 3;
        double topOffset = size.y / 2.5;
        double feetOffset = size.y / 10;
        
        newPosition.x = newPosition.x.clamp(minX + xOffset, maxX - xOffset);
        
        if (newPosition.y < minY + topOffset) {
          newPosition.y = minY + topOffset;
        }
        if (newPosition.y > maxY - feetOffset) {
          newPosition.y = maxY - feetOffset;
        }
      }
      
      // Apply the new position
      position = newPosition;
      
      // End slide if duration is over
      if (_slideTimer >= _slideDuration) {
        _isSliding = false;
        _isInvulnerable = false;
        _returnToIdle();
      }
    } else if (!_isAttacking) {
      // Move player if not attacking
      if (movementDirection.length > 0) {
        Vector2 newPosition = position + movementDirection * speed * dt;
        
        // Enforce boundaries if they're set
        if (_boundariesSet) {
          double xOffset = size.x / 3;
          double topOffset = size.y / 2.5;
          double feetOffset = size.y / 10;
          
          newPosition.x = newPosition.x.clamp(minX + xOffset, maxX - xOffset);
          
          if (newPosition.y < minY + topOffset) {
            newPosition.y = minY + topOffset;
          }
          if (newPosition.y > maxY - feetOffset) {
            newPosition.y = maxY - feetOffset;
          }
        }
        
        // Apply the new position
        position = newPosition;
      }
    }
  }
  
  void takeDamage(double amount) {
    if (_isInvulnerable) return;
    
    health -= amount;
    if (health <= 0) {
      die();
    } else {
      // Flash red or show damage effect
    }
  }
  
  void die() {
    game.endGame();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (_isAttacking && other is Enemy) {
      other.takeDamage(attackPower);
      print('$attackPower');
    }
  }
}
