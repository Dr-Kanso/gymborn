import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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
    _setupGame();
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
      body: Column(
        children: [
          Expanded(
            child: GameWidget<GymGame>(
              game: _game,
              loadingBuilder:
                  (context) => const Center(
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
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: kBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dungeon Level 1',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Pause or access game menu
                    showGameMenu(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  child: const Text('Menu'),
                ),
              ],
            ),
          ),
        ],
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

  void showGameMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Menu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.refresh, color: kPrimaryColor),
                title: const Text('Restart Level'),
                onTap: () {
                  Navigator.pop(context);
                  // Restart level logic
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: kPrimaryColor),
                title: const Text('Game Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Open game settings
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: kPrimaryColor),
                title: const Text('Exit Game'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
