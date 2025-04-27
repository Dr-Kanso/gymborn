import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class VictoryMessage extends PositionComponent
    with TapCallbacks, HasGameReference {
  final String message;
  final Function? onNextLevel;
  final math.Random _random = math.Random();
  late SpriteAnimationComponent _victoryAnimation;

  VictoryMessage({
    required this.message,
    required Vector2 screenSize,
    this.onNextLevel,
    super.priority = 10,
  }) : super(
         // Position component at the exact center of the screen
         position: Vector2(screenSize.x / 2, screenSize.y / 2),
         // Set anchor to center to ensure proper centering
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Load the custom animation from the JSON file
      final sprites = await game.images.load('ui/level_cleared.png');
      final animation = SpriteAnimation.fromFrameData(
        sprites,
        SpriteAnimationData.sequenced(
          amount: 40, // 40 frames in the JSON file
          stepTime: 0.05,
          textureSize: Vector2(858, 399), // Size from the JSON
          loop: false,
        ),
      );

      // Create and add the animation component - center it within this component
      _victoryAnimation = SpriteAnimationComponent(
        animation: animation,
        size: Vector2(858, 399) * 0.8, // Scale down slightly
        anchor: Anchor.center,
        position: Vector2.zero(), // Center in parent
      );
      add(_victoryAnimation);

      // Calculate appropriate position for button - below the animation
      final buttonY =
          _victoryAnimation.size.y / 2 + 40; // Half animation height + spacing

      // Add Next Level button if callback provided
      if (onNextLevel != null) {
        final buttonComponent = _NextLevelButtonComponent(
          onNextLevel: onNextLevel!,
          position: Vector2(
            0,
            buttonY,
          ), // Centered horizontally, positioned below animation
          anchor: Anchor.center,
          size: Vector2(220, 60),
        );

        buttonComponent.add(
          ScaleEffect.by(
            Vector2.all(1.05), // Subtle scale change
            EffectController(
              duration: 0.8,
              reverseDuration: 0.8,
              infinite: true,
              curve: Curves.easeInOut,
            ),
          ),
        );

        add(buttonComponent);
      }

      // Add celebration effects
      _addCelebrationEffects();
    } catch (e) {
      debugPrint('Error setting up victory message: $e');
    }
  }

  void _addCelebrationEffects() {
    // Add floating confetti for extra celebration
    final screenSize = game.size;
    for (int i = 0; i < 30; i++) {
      final confetti = _createConfetti();
      confetti.position = Vector2(
        _random.nextDouble() * screenSize.x - screenSize.x / 2,
        _random.nextDouble() * -100 - 50,
      );

      // Add falling movement
      confetti.add(
        MoveEffect.by(
          Vector2(
            (_random.nextDouble() - 0.5) * 300,
            300 + _random.nextDouble() * 200,
          ),
          EffectController(
            duration: 3 + _random.nextDouble() * 4,
            curve: Curves.easeIn,
          ),
          onComplete: () => confetti.removeFromParent(),
        ),
      );

      // Add rotation
      confetti.add(
        RotateEffect.by(
          _random.nextDouble() * 10,
          EffectController(
            duration: 2 + _random.nextDouble() * 3,
            infinite: true,
          ),
        ),
      );

      add(confetti);
    }
  }

  PositionComponent _createConfetti() {
    final color = _getRandomFestiveColor();
    final size = 5 + _random.nextDouble() * 10;

    return RectangleComponent(
      size: Vector2(size, size),
      paint: Paint()..color = color,
      anchor: Anchor.center,
    );
  }

  Color _getRandomFestiveColor() {
    final colors = [
      Colors.amber,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.green,
    ];
    return colors[_random.nextInt(colors.length)];
  }
}

// Enhanced custom component for the button
class _NextLevelButtonComponent extends PositionComponent
    with TapCallbacks, HasGameReference {
  final Function onNextLevel;

  _NextLevelButtonComponent({
    required this.onNextLevel,
    required super.position,
    required Vector2 size,
    super.anchor = Anchor.center,
  }) : super(size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Replace complex button building with a simple sprite
      final buttonSprite = await game.images.load('ui/next_level_button.png');
      final buttonComponent = SpriteComponent(
        sprite: Sprite(buttonSprite),
        size: size,
        anchor: Anchor.center,
      );

      // Add the sprite to the component
      add(buttonComponent);

      // Add a glowing effect
      final glowEffect = _GlowComponent(
        size: Vector2(size.x + 16, size.y + 16),
        position: Vector2(-8, -8),
        color: Colors.amber,
        innerRadius: 12,
      );
      add(glowEffect);
    } catch (e) {
      debugPrint('Error loading Next Level button: $e');
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(0.95); // Pressed effect
    onNextLevel();
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}

// Glow component for button effects
class _GlowComponent extends CustomPainterComponent {
  final Color color;
  final double innerRadius;
  double pulsePhase = 0.0;

  _GlowComponent({
    required super.size,
    required super.position,
    required this.color,
    required this.innerRadius,
  }) : super(painter: _GlowPainter(color, innerRadius, 0.0));

  @override
  void update(double dt) {
    super.update(dt);

    // Update the glow pulse
    pulsePhase = (pulsePhase + dt) % 6.28; // 2*pi
    final intensity = 0.6 + 0.4 * (0.5 + 0.5 * sin(pulsePhase));

    // Update the painter with new intensity
    painter = _GlowPainter(color, innerRadius, intensity);
  }
}

class _GlowPainter extends CustomPainter {
  final Color color;
  final double innerRadius;
  final double intensity;

  _GlowPainter(this.color, this.innerRadius, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(innerRadius + 4),
    );

    // Create a glow effect with a gradient
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..color = color.withAlpha((255 * intensity).round());

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldPainter) {
    return color != oldPainter.color ||
        innerRadius != oldPainter.innerRadius ||
        intensity != oldPainter.intensity;
  }
}
