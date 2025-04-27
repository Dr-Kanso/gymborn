import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/player.dart';

class PlayerComponent extends PositionComponent with HasGameReference {
  final Player player;

  // Store original sprite sheets - make nullable to avoid late init errors
  ui.Image? _idleSpriteSheet;
  ui.Image? _attackSpriteSheet;
  ui.Image? _hurtSpriteSheet;
  ui.Image? _deathSpriteSheet;

  late SpriteAnimationComponent _idleAnimation;
  late SpriteAnimationComponent _attackAnimation;
  late SpriteAnimationComponent _hurtAnimation;
  late SpriteAnimationComponent _deathAnimation;
  late SpriteAnimationComponent _celebrateAnimation;

  bool _isAttacking = false;
  bool _isHurt = false;
  bool _isDying = false;
  bool _isCelebrating = false;

  // Current visible animation
  SpriteAnimationComponent? _currentAnimation;

  PlayerComponent(this.player)
    : super(priority: 2); // Higher priority for player

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Load sprite sheets
      await _loadAnimations();

      // Show idle animation by default
      _currentAnimation = _idleAnimation;
      add(_currentAnimation!);
    } catch (e) {
      debugPrint('Error loading player component: $e');
    }
  }

  Future<void> _loadAnimations() async {
    try {
      // Access game.images
      _idleSpriteSheet = await game.images.load('characters/women_idle.png');
      _attackSpriteSheet = await game.images.load(
        'characters/women_slashing.png',
      );
      _hurtSpriteSheet = await game.images.load('characters/women_hurt.png');
      _deathSpriteSheet = await game.images.load('characters/women_hurt.png');
      // Add proper celebrate spritesheet
      final celebrateSpriteSheet = await game.images.load(
        'characters/celebrate.png',
      );

      // Create animations with appropriate speeds
      _idleAnimation = _createAnimation(
        _idleSpriteSheet!,
        18,
        0.05,
        loop: true,
      );
      _attackAnimation = _createAnimation(
        _attackSpriteSheet!,
        12,
        0.04,
        loop: false,
      );
      _hurtAnimation = _createAnimation(
        _hurtSpriteSheet!,
        12,
        0.04,
        loop: false,
      );
      _deathAnimation = _createAnimation(
        _deathSpriteSheet!,
        12,
        0.08,
        loop: false,
      );

      // Use proper celebration animation with the celebrate spritesheet
      _celebrateAnimation = _createAnimation(
        celebrateSpriteSheet,
        12, // There are 12 frames in celebrate.json
        0.04, // Slightly slower for a more dramatic celebration
        loop: true,
      );

      debugPrint('Player animations loaded successfully');
    } catch (e) {
      debugPrint('Error loading player animations: $e');
      rethrow;
    }
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
        loop: loop, // use 'loop' parameter
      ),
    );

    return SpriteAnimationComponent(
      animation: animation,
      size: Vector2(300, 300), // Doubled size (was 150, 150)
      anchor: Anchor.center,
    );
  }

  void playAttackAnimation() {
    if (_isAttacking || _isHurt || _isDying || _attackSpriteSheet == null) {
      return;
    }

    debugPrint('Playing player attack animation');
    // Force end any previous animation state
    _isAttacking = false;

    // Then start a fresh animation
    _isAttacking = true;

    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    // Create a completely new animation component each time
    _attackAnimation = _createAnimation(
      _attackSpriteSheet!,
      12,
      0.04,
      loop: false,
    );

    _currentAnimation = _attackAnimation;
    add(_currentAnimation!);
  }

  void _showIdleAnimation() {
    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    _currentAnimation = _idleAnimation;
    add(_currentAnimation!);
  }

  void playHurtAnimation() {
    if (_isHurt || _hurtSpriteSheet == null) return;

    debugPrint('Playing player hurt animation');
    _isHurt = true;
    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    // Recreate animation with consistent timing
    _hurtAnimation = _createAnimation(_hurtSpriteSheet!, 12, 0.04, loop: false);

    _currentAnimation = _hurtAnimation;
    add(_currentAnimation!);
  }

  void playDeathAnimation() {
    if (_isDying) return;

    debugPrint('Playing player death animation');
    _isDying = true;

    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    // Create death animation
    _deathAnimation = _createAnimation(
      _deathSpriteSheet!,
      12,
      0.08,
      loop: false,
    );

    _currentAnimation = _deathAnimation;
    add(_currentAnimation!);
  }

  void playCelebrateAnimation() {
    if (_isCelebrating || _isDying) return;

    debugPrint('Playing celebration animation');
    _isCelebrating = true;

    if (_currentAnimation != null) {
      remove(_currentAnimation!);
    }

    // Use the already created celebration animation instead of recreating it
    _currentAnimation = _celebrateAnimation;
    add(_currentAnimation!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Skip other animations if dying or celebrating
    if (_isDying || _isCelebrating) return;

    // detect animation end by frame index
    final atkAnimTicker = _attackAnimation.animationTicker;
    if (_isAttacking &&
        atkAnimTicker != null &&
        atkAnimTicker.currentIndex ==
            atkAnimTicker.spriteAnimation.frames.length - 1) {
      _isAttacking = false;
      _showIdleAnimation();
    }
    final hurtAnimTicker = _hurtAnimation.animationTicker;
    if (_isHurt &&
        hurtAnimTicker != null &&
        hurtAnimTicker.currentIndex ==
            hurtAnimTicker.spriteAnimation.frames.length - 1) {
      _isHurt = false;
      _showIdleAnimation();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Position player on the right side of screen
    position = Vector2(
      size.x * 0.25, // 25% from the left
      size.y * 0.6, // 60% from the top (bottom part of the screen)
    );
  }

  @override
  void onRemove() {
    // Clean up resources
    _currentAnimation = null;
    super.onRemove();
  }
}
