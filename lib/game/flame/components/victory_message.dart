import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class VictoryMessage extends PositionComponent with TapCallbacks {
  final String message;
  final Function? onNextLevel;
  late TextComponent _textComponent;
  late TextComponent _subtitleComponent;
  final math.Random _random = math.Random();

  VictoryMessage({
    required this.message,
    required Vector2 screenSize,
    this.onNextLevel,
    super.priority = 10,
  }) : super(position: Vector2(screenSize.x / 2, screenSize.y * 0.4)) {
    // Create main text component with larger text
    _textComponent = TextComponent(
      text: message.split("\n")[0], // Get the main title part
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 48.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 15, color: Colors.orange, offset: Offset(2, 2)),
            Shadow(blurRadius: 30, color: Colors.red, offset: Offset(4, 4)),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    // Create subtitle with smaller text if there's a second line
    final parts = message.split("\n");
    if (parts.length > 1) {
      _subtitleComponent = TextComponent(
        text: parts[1],
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(0, 60), // Position below main text
      );
      add(_subtitleComponent);
    }

    // Add the main text component
    add(_textComponent);

    // Add Next Level button if callback provided
    if (onNextLevel != null) {
      // Create a custom button component with tap handling
      final buttonComponent = _NextLevelButtonComponent(
        onNextLevel: onNextLevel!,
        position: Vector2(0, 120),
        anchor: Anchor.center,
        size: Vector2(220, 60), // Larger button size
      );

      // Add pulsing effect with smoother animation
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

    // Add simple celebration effects
    _addCelebrationEffects(screenSize);
  }

  void _addCelebrationEffects(Vector2 screenSize) {
    // Add floating confetti instead of complex particles
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

  // Animation variables
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Update animation time
    _time += dt;

    // Create pulsing and floating effect
    final pulseFactor = 1.0 + 0.1 * math.sin(_time * 3);
    final floatOffset = 5 * math.sin(_time * 2);

    // Apply effects to text
    _textComponent.scale = Vector2.all(pulseFactor);
    _textComponent.position.y = floatOffset;

    // Apply color cycling effect
    final hue = (_time * 20) % 360;
    _textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: HSVColor.fromAHSV(1.0, hue, 0.7, 1.0).toColor(),
        fontSize: 48.0,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(blurRadius: 15, color: Colors.orange, offset: Offset(2, 2)),
          Shadow(blurRadius: 30, color: Colors.red, offset: Offset(4, 4)),
        ],
      ),
    );
  }
}

// Enhanced custom component for the button
class _NextLevelButtonComponent extends PositionComponent with TapCallbacks {
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

    // Add pulsating glow behind the button
    final glowEffect = _GlowComponent(
      size: Vector2(size.x + 16, size.y + 16),
      position: Vector2(-8, -8),
      color: Colors.amber,
      innerRadius: 12,
    );
    add(glowEffect);

    // Create button with rounded corners and gradient
    final buttonBackground = _GradientRectComponent(
      size: size,
      startColor: const Color(0xFF4CAF50), // Material green
      endColor: const Color(0xFF2E7D32), // Dark green
      borderRadius: 12,
    );

    // Add button border
    final buttonBorder = _RoundedRectangleComponent(
      size: Vector2(size.x, size.y),
      paint:
          Paint()
            ..color = Colors.yellow
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
      radius: 12,
    );

    // Create container for text and arrow to ensure proper centering
    final textContainer = PositionComponent(
      size: size,
      position: Vector2.zero(),
    );

    // Button text with appropriate styling (centered in container)
    final buttonText = TextComponent(
      text: "NEXT LEVEL",
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2), // Center in container
    );

    // Add decorative arrow icon
    final arrowIcon = TextComponent(
      text: "→",
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(size.x - 35, size.y / 2), // Right-aligned
    );

    // Build the button
    add(buttonBackground);
    add(buttonBorder);
    // Add container with centered elements
    textContainer.add(buttonText);
    textContainer.add(arrowIcon);
    add(textContainer);
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

// Add a new glow component that animates itself without using OpacityEffect
class _GlowComponent extends CustomPainterComponent {
  final Color color;
  final double innerRadius;
  double pulsePhase = 0.0;

  _GlowComponent({
    required super.size,
    super.position,
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
    // Fix deprecation by using .withOpacity instead of .withAlpha
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..color = color.withOpacity(
            intensity,
          ); // Fixed: use withOpacity instead of withAlpha

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldPainter) {
    return color != oldPainter.color ||
        innerRadius != oldPainter.innerRadius ||
        intensity != oldPainter.intensity;
  }
}

// Custom component for rounded rectangles (since RectangleComponent doesn't support borderRadius)
class _RoundedRectangleComponent extends CustomPainterComponent {
  final Paint paint;
  final double radius;

  _RoundedRectangleComponent({
    required Vector2 size,
    required this.paint,
    required this.radius,
    Vector2? position,
    Anchor? anchor,
  }) : super(
         size: size,
         position: position,
         anchor: anchor ?? Anchor.topLeft, // Provide default anchor if null
         painter: _RoundedRectPainter(paint, radius),
       );
}

class _RoundedRectPainter extends CustomPainter {
  final Paint _paint;
  final double radius;

  _RoundedRectPainter(this._paint, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rRect, _paint);
  }

  @override
  bool shouldRepaint(_RoundedRectPainter oldPainter) {
    return _paint != oldPainter._paint || radius != oldPainter.radius;
  }
}

// Custom component for gradient rectangle with rounded corners
class _GradientRectComponent extends CustomPainterComponent {
  final Color startColor;
  final Color endColor;
  final double borderRadius;

  _GradientRectComponent({
    required Vector2 size,
    required this.startColor,
    required this.endColor,
    this.borderRadius = 0,
  }) : super(
         size: size,
         painter: _GradientRectPainter(startColor, endColor, borderRadius),
       );
}

class _GradientRectPainter extends CustomPainter {
  final Color startColor;
  final Color endColor;
  final double borderRadius;

  _GradientRectPainter(this.startColor, this.endColor, this.borderRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect);

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(_GradientRectPainter oldPainter) {
    return startColor != oldPainter.startColor ||
        endColor != oldPainter.endColor ||
        borderRadius != oldPainter.borderRadius;
  }
}
