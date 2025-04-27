import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class VictoryMessage extends PositionComponent {
  final String message;
  late TextComponent _textComponent;
  late TextComponent _subtitleComponent;
  final math.Random _random = math.Random();

  VictoryMessage({
    required this.message,
    required Vector2 screenSize,
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

    // Add particles for celebration effect
    _addParticles(screenSize);
  }

  void _addParticles(Vector2 screenSize) {
    // Add particle effects around the text
    for (int i = 0; i < 20; i++) {
      add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 10,
            lifespan: 2,
            generator:
                (i) => AcceleratedParticle(
                  acceleration: Vector2(0, 25),
                  speed: Vector2(
                    _random.nextDouble() * 200 - 100,
                    _random.nextDouble() * -100 - 50,
                  ),
                  position: Vector2(
                    _random.nextDouble() * 200 - 100,
                    _random.nextDouble() * 50,
                  ),
                  child: CircleParticle(
                    radius: 3 + _random.nextDouble() * 3,
                    paint: Paint()..color = _getRandomFestiveColor(),
                  ),
                ),
          ),
        ),
      );
    }
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
