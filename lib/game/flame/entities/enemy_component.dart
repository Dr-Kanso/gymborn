import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/enemy.dart';

class EnemyComponent extends PositionComponent
    with HasGameReference, TapCallbacks {
  final Enemy enemy;

  // Store original sprite sheets - make nullable to avoid late init errors
  ui.Image? _idleSpriteSheet;
  ui.Image? _attackSpriteSheet;
  ui.Image? _hurtSpriteSheet;
  ui.Image? _deathSpriteSheet;

  late SpriteAnimationComponent _idleAnimation;
  late SpriteAnimationComponent _attackAnimation;
  late SpriteAnimationComponent _hurtAnimation;
  late SpriteAnimationComponent _deathAnimation;

  late TextComponent _healthText;
  late RectangleComponent _healthBar;
  // late RectangleComponent _healthBarBackground; // Removed as it's not used

  bool _isAttacking = false;
  bool _isHurt = false;
  bool _isDying = false;

  // Current visible animation
  SpriteAnimationComponent? _currentAnimation;

  EnemyComponent(this.enemy) : super(priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Load sprite sheets
      await _loadAnimations();

      // Show idle animation by default
      _currentAnimation = _idleAnimation;
      add(_currentAnimation!);

      // Add health bar
      await _setupHealthBar();
    } catch (e) {
      debugPrint('Error loading enemy component: $e');
    }
  }

  Future<void> _loadAnimations() async {
    // Load all animation spritesheets
    _idleSpriteSheet = await game.images.load('dungeons/enemy.png');
    _attackSpriteSheet = await game.images.load('dungeons/enemy_slashing.png');
    _hurtSpriteSheet = await game.images.load('dungeons/enemy_hurt.png');
    _deathSpriteSheet = await game.images.load('dungeons/enemy_death.png');

    // Create sprite sheets and animations
    _idleAnimation = _createAnimation(_idleSpriteSheet!, 18, 0.05, loop: true);
    _attackAnimation = _createAnimation(
      _attackSpriteSheet!,
      12,
      0.1,
      loop: false,
    );
    _hurtAnimation = _createAnimation(_hurtSpriteSheet!, 12, 0.1, loop: false);
    _deathAnimation = _createAnimation(
      _deathSpriteSheet!,
      15,
      0.1,
      loop: false,
    );
  }

  SpriteAnimationComponent _createAnimation(
    ui.Image spriteSheet,
    int frameCount,
    double stepTime, {
    bool loop = true,
  }) {
    // Create the animation from the spritesheet
    final animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: Vector2(900, 900),
        loop: loop,
      ),
    );

    final component = SpriteAnimationComponent(
      animation: animation,
      size: Vector2(300, 300), // Doubled size (was 150, 150)
      anchor: Anchor.center,
    );

    // Flip the enemy horizontally to face the player
    component.scale = Vector2(-1, 1);

    return component;
  }

  Future<void> _setupHealthBar() async {
    // Remove visible health bars since we're showing them in the UI
    // Keep the components initialized but don't add them to the component
    // _healthBarBackground = RectangleComponent( // Removed as it's not used
    //   size: Vector2(120, 12),
    //   paint: Paint()..color = Colors.grey.shade300,
    //   position: Vector2(0, -40),
    // );

    _healthBar = RectangleComponent(
      size: Vector2(120 * (enemy.health / enemy.maxHealth), 12),
      paint: Paint()..color = Colors.red,
      position: Vector2(0, -40),
    );

    _healthText = TextComponent(
      text: "${enemy.health}/${enemy.maxHealth}",
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      position: Vector2(0, -60),
    );

    // Don't add health components to the entity
    // They'll be displayed in the UI instead
  }

  void updateHealth(int health, int maxHealth) {
    _healthBar.size.x = 120 * (health / maxHealth); // Match the new width
    _healthText.text = "$health/$maxHealth";
  }

  void playAttackAnimation() {
    if (_isAttacking || _isDying || _attackSpriteSheet == null) return;

    _isAttacking = true;
    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    try {
      // Recreate animation using stored sprite sheet
      _attackAnimation = _createAnimation(
        _attackSpriteSheet!,
        12,
        0.04, // Increase duration
        loop: false,
      );

      _currentAnimation = _attackAnimation;
      add(_currentAnimation!);
    } catch (e) {
      debugPrint('Error playing attack animation: $e');
      _isAttacking = false;
      _showIdleAnimation(); // Fall back to idle animation
    }
  }

  void playHurtAnimation() {
    if (_isHurt || _isDying || _hurtSpriteSheet == null) {
      return; // Added null check
    }

    _isHurt = true;
    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    try {
      // Recreate animation using stored sprite sheet
      _hurtAnimation = _createAnimation(
        _hurtSpriteSheet!,
        12,
        0.04,
        loop: false,
      );

      _currentAnimation = _hurtAnimation;
      add(_currentAnimation!);
    } catch (e) {
      debugPrint('Error playing hurt animation: $e');
      _isHurt = false;
      _showIdleAnimation(); // Fall back to idle animation
    }
  }

  void playDeathAnimation() {
    if (_isDying || _deathSpriteSheet == null) return;

    _isDying = true;
    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    try {
      // Recreate animation using stored sprite sheet
      _deathAnimation = _createAnimation(
        _deathSpriteSheet!,
        15,
        0.04,
        loop: false,
      );

      _currentAnimation = _deathAnimation;
      add(_currentAnimation!);
    } catch (e) {
      debugPrint('Error playing death animation: $e');
      // Fall back to another animation or placeholder
      _showIdleAnimation();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for attack animation completion
    final atkAnimTicker = _attackAnimation.animationTicker;
    if (_isAttacking &&
        atkAnimTicker != null &&
        atkAnimTicker.currentIndex ==
            atkAnimTicker.spriteAnimation.frames.length - 1) {
      _isAttacking = false;
      _showIdleAnimation();
    }

    // Check for hurt animation completion
    final hurtAnimTicker = _hurtAnimation.animationTicker;
    if (_isHurt &&
        hurtAnimTicker != null &&
        hurtAnimTicker.currentIndex ==
            hurtAnimTicker.spriteAnimation.frames.length - 1) {
      _isHurt = false;
      _showIdleAnimation();
    }

    // Check for death animation completion
    final deathAnimTicker = _deathAnimation.animationTicker;
    if (_isDying &&
        deathAnimTicker != null &&
        deathAnimTicker.currentIndex ==
            deathAnimTicker.spriteAnimation.frames.length - 1) {
      // Keep showing death frame, don't reset to idle
    }
  }

  void _showIdleAnimation() {
    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }
    if (_idleSpriteSheet != null) {
      // Recreate idle animation to ensure fresh state
      _idleAnimation = _createAnimation(
        _idleSpriteSheet!,
        18,
        0.05,
        loop: true,
      );
      _currentAnimation = _idleAnimation;
      add(_currentAnimation!);
    }
  }

  @override
  void onRemove() {
    // Clean up resources when component is removed
    _currentAnimation = null;
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Position enemy on the right side of screen
    position = Vector2(
      size.x * 0.75, // 75% from the left
      size.y * 0.6, // 60% from the top (bottom part of the screen)
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Handle tap down event if needed, e.g., trigger player attack
    // For now, just consuming the event might not be necessary unless
    // you want to prevent other components below from receiving the tap.
    // If you don't need to do anything, you can remove this override.
    super.onTapDown(event);
  }
}
