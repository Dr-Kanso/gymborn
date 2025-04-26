import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for orientation control
import 'package:provider/provider.dart';

import '../../game/gym_game.dart';
import '../../providers/stats_provider.dart';
import '../../themes/theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GymGame _game;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation when entering game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _setupGame();
  }

  @override
  void dispose() {
    // Force portrait orientation when leaving the game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _setupGame() {
    final statsProvider = Provider.of<StatsProvider>(context, listen: false);
    _game = GymGame(statsProvider: statsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dungeon Adventure'),
        backgroundColor: kPrimaryColor,
      ),
      body: GameWidget<GymGame>(
        game: _game,
        loadingBuilder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading Dungeon...'),
            ],
          ),
        ),
        overlayBuilderMap: {
          'touchControls': (context, game) {
            return Positioned(
              bottom: 20,
              left: 20,
              child: joystickComponent(
                onDirectionChanged: (direction) {
                  game.player.move(direction);
                },
              ),
            );
          },
          'attackButton': (context, game) {
            return Positioned(
              bottom: 30,
              right: 30,
              child: GestureDetector(
                onTap: () => game.player.attack(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withAlpha((0.7 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            );
          },
        },
      ),
    );
  }

  // Create a joystick component for touch controls (renamed to lowerCamelCase)
  Widget joystickComponent({required Function(Vector2) onDirectionChanged}) {
    return StatefulBuilder(
      builder: (context, setState) {
        Vector2 direction = Vector2.zero();

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: kPrimaryColor.withAlpha((0.2 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onPanStart: (details) {
              final center = const Offset(60, 60);
              final touchPosition = details.localPosition;
              direction = Vector2(
                touchPosition.dx - center.dx,
                touchPosition.dy - center.dy,
              );
              direction = direction.normalized();
              onDirectionChanged(direction);
              setState(() {});
            },
            onPanUpdate: (details) {
              final center = const Offset(60, 60);
              final touchPosition = details.localPosition;
              direction = Vector2(
                touchPosition.dx - center.dx,
                touchPosition.dy - center.dy,
              );
              direction = direction.normalized();
              onDirectionChanged(direction);
              setState(() {});
            },
            onPanEnd: (details) {
              direction = Vector2.zero();
              onDirectionChanged(direction);
              setState(() {});
            },
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha((0.8 * 255).round()),
                  shape: BoxShape.circle,
                ),
                margin: EdgeInsets.only(
                  left: direction.x * 30,
                  top: direction.y * 30,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
