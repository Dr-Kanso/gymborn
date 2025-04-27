import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageIndicator extends TextComponent {
  final Vector2 startPosition;
  final double duration;
  final bool isHeal;

  double _lifeTime = 0;
  late Vector2 _velocity;
  final math.Random _random = math.Random();

  DamageIndicator({
    required int amount,
    required this.startPosition,
    this.duration = 1.0,
    this.isHeal = false,
    super.priority = 10,
  }) : super(
         text: amount.toString(),
         textRenderer: TextPaint(
           style: TextStyle(
             color: isHeal ? Colors.green : Colors.red,
             fontSize: 24, // Larger damage text to match character size
             fontWeight: FontWeight.bold,
           ),
         ),
       ) {
    // Set upward and slightly randomized horizontal velocity
    _velocity = Vector2(
      (_random.nextDouble() - 0.5) * 20, // Small random horizontal movement
      -60, // Upward movement
    );

    // Center the text at start position
    anchor = Anchor.center;
    position = startPosition.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _lifeTime += dt;

    // Update position based on velocity
    position += _velocity * dt;

    // Slow down as it rises
    _velocity.y *= 0.95;

    // Fade out over time
    if (_lifeTime > duration * 0.5) {
      final opacity = 1.0 - ((_lifeTime - duration * 0.5) / (duration * 0.5));
      final textPaint = textRenderer as TextPaint;
      final currentColor = textPaint.style.color!;

      textRenderer = TextPaint(
        style: textPaint.style.copyWith(
          color: currentColor.withAlpha(
            (opacity.clamp(0.0, 1.0) * 255).toInt(),
          ),
        ),
      );
    }

    // Remove when duration is complete
    if (_lifeTime >= duration) {
      removeFromParent();
    }
  }
}
