import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

enum EnemyState { idle, hurt, running, slashing }

class Enemy extends SpriteAnimationComponent with HasGameReference {
  // Animation properties
  late Map<EnemyState, SpriteAnimation> animations;
  EnemyState currentState = EnemyState.idle;
  
  // Track non-looping animations current frame
  final Map<EnemyState, bool> _nonLoopingStates = {
    EnemyState.hurt: true,
    EnemyState.slashing: true,
  };

  // Combat properties
  double health = 100;
  double maxHealth = 100;
  bool isDead = false;
  
  // Movement properties
  Vector2 movementDirection = Vector2.zero(); // Added for movement tracking
  
  // Movement boundaries
  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;
  double detectionRadius = 150;

  Enemy({required Vector2 position, required Vector2 size}) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimations();
    animation = animations[currentState];
  }

  Future<void> _loadAnimations() async {
    // Load all animations from sprite sheets
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

    // Create animations from sprite sheets
    animations = {
      EnemyState.idle: idleSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: 17, // Based on enemy.json having 18 frames (0-17)
      ),
      EnemyState.hurt: hurtSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: 11, // Based on enemy_hurt.json having 12 frames (0-11)
        loop: false,
      ),
      EnemyState.slashing: slashingSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: 11, // Based on enemy_slashing.json having 12 frames (0-11)
        loop: false,
      ),
      EnemyState.running: runningSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: 10, // Based on enemy_running.json having 11 frames (0-10)
      ),
    };
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
      _returnToIdle();
    }
    
    // Fix boundary enforcement - ensure enemies stay fully visible
    // Use more accurate offsets based on sprite dimensions
    double xOffset = size.x / 3; // Match player's horizontal offset
    
    // Adjust offsets to match visual appearance of sprites
    double topOffset = size.y / 2.5;  // Prevent head from entering ceiling
    double bottomOffset = size.y / 5;  // Ensure feet stay fully above the boundary
    
    double newX = position.x.clamp(_minX + xOffset, _maxX - xOffset);
    
    // Apply separate boundary logic for top and bottom
    double newY = position.y;
    
    // For top boundary: keep the head below the ceiling
    if (position.y < _minY + topOffset) {
      newY = _minY + topOffset;
    }
    
    // For bottom boundary: keep the full sprite above the boundary
    if (position.y > _maxY - bottomOffset) {
      newY = _maxY - bottomOffset; 
    }
    
    // Only update if position changed to avoid unnecessary updates
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
    
    // Set animation to first frame
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
    if (health <= 0) {
      health = 0;
      isDead = true;
    }
    
    changeState(EnemyState.hurt);
  }

  void startRunning() {
    if (isDead) return;
    changeState(EnemyState.running);
  }

  void attack() {
    if (isDead) return;
    changeState(EnemyState.slashing);
  }

  void move(Vector2 direction) {
    movementDirection = direction;
    
    // Update sprite horizontal direction based on movement
    if (direction.x < 0 && !isFlippedHorizontally) {
      flipHorizontally();
    } else if (direction.x > 0 && isFlippedHorizontally) {
      flipHorizontally(); // Flip back to original orientation
    }
    
    // Update state based on movement
    if (direction.length > 0 && currentState != EnemyState.slashing) {
      changeState(EnemyState.running);
    } else if (direction.length == 0 && currentState != EnemyState.slashing) {
      changeState(EnemyState.idle);
    }
  }
}
