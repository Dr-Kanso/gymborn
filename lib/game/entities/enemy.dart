import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:gymborn_app/game/engine/gym_game.dart';
import 'package:gymborn_app/game/entities/player.dart'; // Import Player

enum EnemyState { idle, hurt, running, slashing, dying }

class Enemy extends SpriteAnimationComponent
    with HasGameReference<GymGame>, CollisionCallbacks {
  // Animation properties
  late Map<EnemyState, SpriteAnimation> animations;
  EnemyState currentState = EnemyState.idle;

  // Track non-looping animations current frame
  final Map<EnemyState, bool> _nonLoopingStates = {
    EnemyState.hurt: true,
    EnemyState.slashing: true,
    EnemyState.dying: true,
  };

  // Combat properties
  double health = 100;
  double maxHealth = 100;
  bool isDead = false;
  double attackPower = 5; // Enemy attack damage
  double attackRange = 80; // Distance within which the enemy attacks
  double attackCooldown = 2.0; // Seconds between attacks
  double _timeSinceLastAttack = 0;
  bool _isAttacking = false; // Track if currently attacking
  RectangleHitbox? _attackHitbox; // Hitbox for the enemy's attack

  // Movement properties
  Vector2 movementDirection = Vector2.zero();
  double speed = 80; // Enemy movement speed

  // Movement boundaries
  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;
  double detectionRadius = 150;
  final dynamic statsProvider;

  Enemy({
    required this.statsProvider,
    Vector2? position,
    Vector2? size,
  }) : super(
         position: position ?? Vector2.zero(),
         size: size ?? Vector2(128, 128),
         anchor: Anchor.center,
       );
       
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimations();
    animation = animations[currentState];

    // Add a hitbox for collision detection with player body/attacks
    add(RectangleHitbox(
      size: size * 0.6, // Smaller hitbox for body
      position: size * 0.2, // Center it
      anchor: Anchor.topLeft,
      collisionType: CollisionType.passive, // Passive for player attacks
    ));
  }

  Future<void> _loadAnimations() async {
    final idleSpriteSheet = SpriteSheet(
      image: await game.images.load('dungeons/enemy.png'),
      srcSize: Vector2(900, 900),
    );

    final hurtSpriteSheet = SpriteSheet(
      image: await game.images.load('dungeons/enemy_hurt.png'),
      srcSize: Vector2(900, 900),
    );

    final slashingSpriteSheet = SpriteSheet(
      image: await game.images.load('dungeons/enemy_slashing.png'),
      srcSize: Vector2(900, 900),
    );

    final runningSpriteSheet = SpriteSheet(
      image: await game.images.load('dungeons/enemy_running.png'),
      srcSize: Vector2(900, 900),
    );

    final deathSpriteSheet = SpriteSheet(
      image: await game.images.load('dungeons/enemy_death.png'),
      srcSize: Vector2(900, 900),
    );

    animations = {
      EnemyState.idle: idleSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: 17,
      ),
      EnemyState.hurt: hurtSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.05,
        to: 11,
        loop: false,
      ),
      EnemyState.slashing: slashingSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.05,
        to: 11,
        loop: false,
      ),
      EnemyState.running: runningSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: 10,
      ),
      EnemyState.dying: deathSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: 14,
        loop: false,
      ),
    };
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastAttack += dt;

    if (isDead) return;

    // --- Animation Completion Logic ---
    if (_nonLoopingStates[currentState] == true &&
        animationTicker != null &&
        animationTicker!.isLastFrame &&
        animation != null &&
        !animation!.loop) {
      if (currentState == EnemyState.slashing) {
        _isAttacking = false;
        // Ensure hitbox is removed if it still exists when animation ends
        if (_attackHitbox != null && _attackHitbox!.parent != null) {
          _attackHitbox!.removeFromParent();
          _attackHitbox = null;
        }
      }
      _returnToIdle();
      return;
    }

    // --- AI Logic ---
    final player = game.player;
    double distanceToPlayer = position.distanceTo(player.position);

    if (distanceToPlayer <= attackRange &&
        _timeSinceLastAttack >= attackCooldown &&
        !_isAttacking) {
      attack(); // Initiate attack state
    } else if (!_isAttacking) {
      if (distanceToPlayer > attackRange && distanceToPlayer <= detectionRadius) {
        movementDirection = (player.position - position).normalized();
        move(movementDirection);
      } else {
        move(Vector2.zero());
      }

      if (currentState == EnemyState.running) {
        position += movementDirection * speed * dt;
      }
    }

    _enforceBoundaries();

    // --- Remove Dynamic Attack Hitbox Logic ---
    // The logic previously here for updating hitbox based on frame is removed.
    // Hitbox is now created in attack() and removed on animation completion.
  }

  void _enforceBoundaries() {
    double xOffset = size.x / 3;
    double topOffset = size.y / 2.5;
    double bottomOffset = size.y / 5;

    double newX = position.x.clamp(_minX + xOffset, _maxX - xOffset);
    double newY = position.y;

    if (position.y < _minY + topOffset) {
      newY = _minY + topOffset;
    }
    if (position.y > _maxY - bottomOffset) {
      newY = _maxY - bottomOffset;
    }

    if (position.x != newX || position.y != newY) {
      position = Vector2(newX, newY);
    }
  }

  void setBoundaries(double minX, double maxX, double minY, double maxY) {
    _minX = minX;
    _maxX = maxX;
    _minY = minY;
    _maxY = maxY;
  }

  void changeState(EnemyState newState) {
    if (isDead && newState != EnemyState.hurt) return;

    currentState = newState;
    animation = animations[newState];

    if (animation != null) {
      animationTicker?.reset();
    }
  }

  void _returnToIdle() {
    if (!isDead) {
      changeState(EnemyState.idle);
    }
  }

  void takeDamage(double amount) {
    if (isDead) return;

    health -= amount;

    paint = Paint()..color = Colors.red.withAlpha((0.8 * 255).toInt());
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!isDead) {
        paint = Paint();
      }
    });

    if (health <= 0) {
      health = 0;
      isDead = true;
      changeState(EnemyState.dying);
      animationTicker?.reset();
      children.whereType<RectangleHitbox>().forEach((hitbox) {
        hitbox.removeFromParent();
      });

      final dyingAnimation = animations[EnemyState.dying];
      final animDuration = dyingAnimation != null
          ? (dyingAnimation.frames.length * dyingAnimation.frames.first.stepTime)
          : (15 * 0.1);

      Future.delayed(Duration(milliseconds: (animDuration * 1000).toInt()), () {
        if (parent != null) {
          removeFromParent();
          game.enemiesDefeated += 1;
        }
      });
    } else {
      if (currentState != EnemyState.slashing && currentState != EnemyState.dying) {
        changeState(EnemyState.hurt);
      }
    }
  }

  void startRunning() {
    if (isDead || _isAttacking) return;
    changeState(EnemyState.running);
  }

  void attack() {
    if (isDead || _isAttacking) return;

    _isAttacking = true;
    _timeSinceLastAttack = 0;
    changeState(EnemyState.slashing);
    movementDirection = Vector2.zero(); // Stop moving

    // Create hitbox ONCE when attack starts, at a fixed position
    final Vector2 hitboxSize = Vector2(size.x * 0.5, size.y * 0.4); // Adjusted size
    // Position based on direction (similar to player's logic)
    final double hitboxOffsetX = size.x * 0.8; // In front
    final double hitboxOffsetY = size.y * 0.4; // Slightly offset vertically

    _attackHitbox = RectangleHitbox(
      position: Vector2(hitboxOffsetX, hitboxOffsetY),
      size: hitboxSize,
      anchor: Anchor.center,
      collisionType: CollisionType.active,
    )..debugMode = true;
    add(_attackHitbox!);
  }

  void move(Vector2 direction) {
    if (_isAttacking || isDead) {
      if (currentState != EnemyState.slashing &&
          currentState != EnemyState.dying &&
          currentState != EnemyState.hurt) {
        changeState(EnemyState.idle);
      }
      movementDirection = Vector2.zero();
      return;
    }

    movementDirection = direction;

    if (direction.x != 0) {
      final playerX = game.player.position.x;
      if (playerX < position.x && !isFlippedHorizontally) {
        flipHorizontally();
      } else if (playerX > position.x && isFlippedHorizontally) {
        flipHorizontally();
      }
    }

    if (direction.length > 0) {
      changeState(EnemyState.running);
    } else {
      changeState(EnemyState.idle);
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // Add null check for _attackHitbox before accessing isRemoving
    if (_isAttacking && other is Player && _attackHitbox != null && !_attackHitbox!.isRemoving) {
      other.takeDamage(attackPower);
    }
  }
}
