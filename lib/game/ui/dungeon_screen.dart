import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../engine/gym_game.dart'; // Changed from game_world.dart
import '../../providers/stats_provider.dart'; // Added StatsProvider import

class DungeonScreen extends StatefulWidget {
  const DungeonScreen({super.key});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  @override
  void initState() {
    super.initState();
    // Force landscape orientation when entering dungeon
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation when leaving the dungeon
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use OrientationBuilder to rebuild properly when orientation changes
    return OrientationBuilder(
      builder: (context, orientation) {
        // Calculate screen dimensions based on current orientation
        final screenSize = MediaQuery.of(context).size;

        // Define playable area boundaries based on the background image
        final topBoundaryPercent = 0.25; // Top 60% is lava
        final bottomBoundaryPercent = 0.30; // Bottom 30% is lava
        final sideBoundaryPercent = 0.05; // Small margin on sides for rock formations
        final playableArea = PlayableArea(
          topMargin: screenSize.height * topBoundaryPercent,
          bottomMargin: screenSize.height * bottomBoundaryPercent,
          leftMargin: screenSize.width * sideBoundaryPercent,
          rightMargin: screenSize.width * sideBoundaryPercent,
        );

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand, // Ensure stack fills the entire screen
            children: [
              // Background image layer with key to force rebuild on orientation change
              Positioned.fill(
                child: Image.asset(
                  'assets/images/dungeons/dungeon_background.png',
                  key: ValueKey('dungeon_bg_${orientation}_${screenSize.width}_${screenSize.height}'),
                  fit: BoxFit.cover,
                  width: screenSize.width,
                  height: screenSize.height,
                ),
              ),

              // Game layer
              Positioned.fill(
                child: GameWidget(
                  game: GymGame( // Changed from GameWorld to GymGame
                    statsProvider: Provider.of<StatsProvider>(context, listen: false),
                    playableArea: playableArea,
                  ),
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
              ),
            ],
          ),
        );
      }
    );
  }
}

// Class to represent the playable area boundaries
class PlayableArea {
  final double topMargin;
  final double bottomMargin;
  final double leftMargin;
  final double rightMargin;

  const PlayableArea({
    required this.topMargin,
    required this.bottomMargin,
    required this.leftMargin,
    required this.rightMargin,
  });
}
