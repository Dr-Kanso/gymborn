import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DungeonLevelTracker extends PositionComponent {
  final int currentLevel;
  final int maxLevels;
  final double circleRadius;
  final double lineThickness;

  DungeonLevelTracker({
    required this.currentLevel,
    required this.maxLevels,
    this.circleRadius = 20,
    this.lineThickness = 5,
    super.position,
    super.priority = 10,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Draw the connecting lines first (lower z-index)
    _addConnectingLines();

    // Draw the level circles
    _addLevelCircles();
  }

  void _addConnectingLines() {
    final Paint linePaint =
        Paint()
          ..color = Colors.grey.withAlpha(179) // 0.7 * 255 ≈ 179
          ..strokeWidth = lineThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Custom draw line component since LineComponent doesn't exist
    add(
      _CustomLineComponent(
        points: List.generate(
          maxLevels,
          (i) => Vector2(i * (circleRadius * 2.5), 0),
        ),
        paint: linePaint,
      ),
    );
  }

  void _addLevelCircles() {
    for (int i = 1; i <= maxLevels; i++) {
      bool isCompleted = i < currentLevel;
      bool isCurrent = i == currentLevel;

      // Get appropriate colors based on completion status
      Color circleColor =
          isCompleted ? Colors.green : (isCurrent ? Colors.amber : Colors.red);

      Color textColor = Colors.white;

      // Position each circle
      final position = Vector2((i - 1) * (circleRadius * 2.5), 0);

      // Create the circle component
      final circle = CircleComponent(
        radius: circleRadius,
        position: position,
        anchor: Anchor.center,
        paint: Paint()..color = circleColor,
      );

      // Add a slight glow effect to the current level
      if (isCurrent) {
        add(
          CircleComponent(
            radius: circleRadius + 5,
            position: position,
            anchor: Anchor.center,
            paint:
                Paint()
                  ..color = Colors.amber.withAlpha(77) // 0.3 * 255 ≈ 77
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3,
          ),
        );
      }

      // Add the circle
      add(circle);

      // Add the level number
      final textComponent = TextComponent(
        text: '$i',
        textRenderer: TextPaint(
          style: TextStyle(
            color: textColor,
            fontSize: circleRadius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: position,
      );

      add(textComponent);
    }
  }

  // Method to update the current level when player progresses
  void updateLevel(int newLevel) {
    removeAll(children);
    _addConnectingLines();
    _addLevelCircles();
  }
}

// Custom line component implementation
class _CustomLineComponent extends Component {
  final List<Vector2> points;
  final Paint paint;

  _CustomLineComponent({required this.points, required this.paint});

  @override
  void render(Canvas canvas) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.x, points.first.y);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }

    canvas.drawPath(path, paint);
  }
}
