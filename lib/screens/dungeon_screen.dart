import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/game_world.dart';

class DungeonScreen extends StatelessWidget {
  const DungeonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: GameWorld(),
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error) => Center(
          child: Text(
            'Error loading game: $error',
            style: const TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
