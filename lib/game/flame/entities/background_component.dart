import 'package:flame/components.dart';

class BackgroundComponent extends SpriteComponent {
  BackgroundComponent()
    : super(priority: -1); // Lower priority to ensure it's rendered first

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the background image
    sprite = await Sprite.load('dungeons/background.png');

    // Size to match the game dimensions (positioned in onGameResize)
    anchor = Anchor.center;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Skip resizing if sprite isn't loaded yet
    if (sprite == null) return;

    // Scale to fit the screen while maintaining aspect ratio
    final aspectRatio = sprite!.originalSize.x / sprite!.originalSize.y;

    if (size.x / size.y > aspectRatio) {
      // Width is the constraint
      width = size.x;
      height = width / aspectRatio;
    } else {
      // Height is the constraint
      height = size.y;
      width = height * aspectRatio;
    }

    // Center the background
    position = size / 2;
  }
}
