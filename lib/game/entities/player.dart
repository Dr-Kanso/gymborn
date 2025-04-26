import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../../providers/stats_provider.dart';
import '../gym_game.dart';

enum PlayerState {
  idle,
  running,
  attacking,
}

class Player extends SpriteAnimationComponent with HasGameReference<GymGame>, CollisionCallbacks {
  // Player properties
  final StatsProvider statsProvider;
  double speed = 150;
  double health = 100;
  double attackPower = 10;
  
  // Movement
  Vector2 movementDirection = Vector2.zero();
  
  // Animations
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation attackingAnimation;
  
  // State
  PlayerState _currentState = PlayerState.idle;
  bool _isAttacking = false;
  
  // Screen boundary constraints
  double minX = 0;
  double maxX = 0;
  double minY = 0;
  double maxY = 0;
  bool _boundariesSet = false;
  
  Player({
    required this.statsProvider,
    Vector2? position,
    Vector2? size,
  }) : super(
         position: position ?? Vector2.zero(),
         size: size ?? Vector2(96, 96),  // Increased from 64x64 to 96x96
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
    animation = idleAnimation;
    
    // Add hitbox for collisions
    add(CircleHitbox(radius: min(size.x, size.y) / 2));
  }
  
  Future<void> _loadAnimations() async {
    // Load idle animation
    final idleImage = await game.images.load('characters/women_idle.png');
    final idleSpriteSheet = SpriteSheet(
      image: idleImage,
      srcSize: Vector2(900, 900),
    );
    idleAnimation = idleSpriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 17);
    
    // Load running animation
    final runningImage = await game.images.load('characters/women_running.png');
    final runningSpriteSheet = SpriteSheet(
      image: runningImage, 
      srcSize: Vector2(900, 900),
    );
    runningAnimation = runningSpriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 11);
    
    // Load attack animation
    final attackImage = await game.images.load('characters/women_slashing.png');
    final attackSpriteSheet = SpriteSheet(
      image: attackImage,
      srcSize: Vector2(900, 900),
    );
    // Make attack animation not looping
    attackingAnimation = attackSpriteSheet.createAnimation(row: 0, stepTime: 0.07, to: 11);
    attackingAnimation.loop = false;
  }
  
  void move(Vector2 direction) {
    movementDirection = direction;
    
    // Update state based on movement
    if (direction.length > 0 && _currentState != PlayerState.attacking) {
      _updateState(PlayerState.running);
    } else if (direction.length == 0 && _currentState != PlayerState.attacking) {
      _updateState(PlayerState.idle);
    }
  }
  
  void attack() {
    if (_currentState != PlayerState.attacking) {
      _isAttacking = true;
      _updateState(PlayerState.attacking);
      
      // Create a timer to handle animation completion since onComplete isn't available
      final animDuration = 0.07 * 11; // stepTime * frame count
      Future.delayed(Duration(milliseconds: (animDuration * 1000).toInt()), () {
        if (_currentState == PlayerState.attacking) {
          _isAttacking = false;
          if (movementDirection.length > 0) {
            _updateState(PlayerState.running);
          } else {
            _updateState(PlayerState.idle);
          }
        }
      });
    }
  }
  
  void _updateState(PlayerState newState) {
    if (_currentState == newState) return;
    
    _currentState = newState;
    
    // Update animation based on state
    switch (newState) {
      case PlayerState.idle:
        animation = idleAnimation;
        break;
      case PlayerState.running:
        animation = runningAnimation;
        break;
      case PlayerState.attacking:
        animation = attackingAnimation;
        // Restart the animation
        animationTicker?.reset();
        break;
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_isAttacking) {
      // Move player if not attacking
      if (movementDirection.length > 0) {
        Vector2 newPosition = position + movementDirection * speed * dt;
        
        // Enforce boundaries if they're set
        if (_boundariesSet) {
          // Clamp to boundaries with offset based on sprite size to prevent visual overflow
          double offset = size.x / 2;
          newPosition.x = newPosition.x.clamp(minX + offset, maxX - offset);
          newPosition.y = newPosition.y.clamp(minY + offset, maxY - offset);
        }
        
        // Apply the new position
        position = newPosition;
      }
      
      // Update state
      if (movementDirection.length == 0 && _currentState == PlayerState.running) {
        _updateState(PlayerState.idle);
      }
    }
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
    // Game over logic
    game.endGame();
  }
}
