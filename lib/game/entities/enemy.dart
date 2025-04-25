import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

enum EnemyState { idle, hurt, running, slashing }

class Enemy extends SpriteAnimationComponent with HasGameRef {
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
      image: await gameRef.images.load('dungeons/enemy.png'),
      srcSize: Vector2(900, 900),
    );

    final hurtSpriteSheet = SpriteSheet(
      image: await gameRef.images.load('dungeons/enemy_hurt.png'),
      srcSize: Vector2(900, 900),
    );

    final slashingSpriteSheet = SpriteSheet(
      image: await gameRef.images.load('dungeons/enemy_slashing.png'),
      srcSize: Vector2(900, 900),
    );

    final runningSpriteSheet = SpriteSheet(
      image: await gameRef.images.load('dungeons/enemy_running.png'),
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
        animation != null && // Ensure animation is not null
        !animation!.loop) { // Access loop from the animation itself
      _returnToIdle();
    }
    
    // Enforce movement boundaries
    if (position.x < _minX) position.x = _minX;
    if (position.x > _maxX) position.x = _maxX;
    if (position.y < _minY) position.y = _minY;
    if (position.y > _maxY) position.y = _maxY;
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
}
