import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class VictoryMessage extends PositionComponent
    with TapCallbacks, HasGameReference {
  final String message;
  final Function? onNextLevel; // Now we'll actually use this parameter
  final math.Random _random = math.Random();
  late SpriteAnimationComponent _victoryAnimation;
  bool _pulsingEffectAdded = false; // Renamed flag for clarity

  VictoryMessage({
    required this.message,
    required Vector2 screenSize,
    this.onNextLevel,
    super.priority = 10,
  }) : super(
         position: Vector2(screenSize.x / 2, screenSize.y / 2),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Load the level cleared animation from JSON file
      final spriteSheet = await game.images.load('ui/level_cleared.png');
      
      // Create animation from the sprite sheet using JSON data
      final animation = SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 40, 
          stepTime: 0.04,
          textureSize: Vector2(796, 492),
          loop: false,
        ),
      );

      // Ensure animation is always centered and stays visible after completion
      _victoryAnimation = SpriteAnimationComponent(
        animation: animation,
        size: Vector2(796, 492) * 0.35,
        anchor: Anchor.center,
        position: Vector2.zero(),
        removeOnFinish: false,
      );

      _victoryAnimation.animationTicker?.onComplete = () {
         debugPrint("Animation complete - adding pulsing effect");
         // Add pulsing effect only once on completion
         if (!_pulsingEffectAdded) {
             _pulsingEffectAdded = true;
             // Add the same pulsing effect used on the button
             _victoryAnimation.add(
                ScaleEffect.by(
                  Vector2.all(1.05), // Same scale factor as button
                  EffectController(
                    duration: 0.8,       // Same duration as button
                    reverseDuration: 0.8, // Same reverse duration as button
                    infinite: true,      // Make it pulse continuously
                    curve: Curves.easeInOut, // Same curve as button
                  ),
                ),
             );
         }
      };

      // Set animation to play once and hold the last frame
      _victoryAnimation.playing = true;
      
      add(_victoryAnimation);

      // Add Next Level button if callback provided
      if (onNextLevel != null) {
        // Load the green button image
        final buttonImage = await game.images.load('ui/next_level_button.png');
        
        // Create button component - positioned at the bottom of the screen like in screenshot
        final buttonSize = Vector2(150, 50);
        
        final buttonComponent = _GreenButtonComponent(  
          sprite: Sprite(buttonImage),
          position: Vector2(0, _victoryAnimation.size.y * 0.6), // Below STAGE CLEARED text
          size: buttonSize,
          onTap: () => onNextLevel!(),
        );
        
        // Add subtle pulsing effect
        buttonComponent.add(
          ScaleEffect.by(
            Vector2.all(1.05),
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

// Simple button component for the next level button
class _GreenButtonComponent extends SpriteComponent with TapCallbacks {
  final Function onTap;
  
  _GreenButtonComponent({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(
    sprite: sprite, 
    position: position, 
    size: size,
    anchor: Anchor.center
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add NEXT LEVEL text to the button
    final textComponent = TextComponent(
      text: 'NEXT LEVEL',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    
    add(textComponent);
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(0.95); // Pressed effect
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    onTap();
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}
