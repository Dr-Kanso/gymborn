import 'package:flutter/material.dart';
import '../../controllers/battle_controller.dart';
import 'image_health_bar_widget.dart'; // Import the new widget

class BattleStatusPanel extends StatelessWidget {
  final BattleController controller;

  const BattleStatusPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    final enemy = controller.currentEnemy;

    if (player == null || enemy == null) {
      return const SizedBox.shrink();
    }

    // Define desired width for the health bars in the panel
    const double healthBarWidth = 200.0; // Changed from 120.0
    // Define desired height or let it be determined by aspect ratio via width
    const double healthBarHeight = 20.0; // Adjust as needed, or set to null

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(top: BorderSide(color: Colors.grey.shade800, width: 2)),
      ),
      child: Row(
        children: [
          // Player stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Prevent column from taking extra space
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Replace _buildHealthBar with ImageHealthBarWidget
                ImageHealthBarWidget(
                  currentHealth: player.health,
                  maxHealth: player.maxHealth,
                  width: healthBarWidth,
                  height: healthBarHeight,
                ),
                const SizedBox(height: 2),
                // Keep or remove HP text based on your preference
                Text(
                  'HP: ${player.health}/${player.maxHealth}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          // VS indicator - replaced with image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              'assets/images/ui/vs.png',
              height: 20.0, // Adjust height as needed
              width: 20.0,  // Adjust width as needed
              fit: BoxFit.contain,
            ),
          ),

          // Enemy stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min, // Prevent column from taking extra space
              children: [
                Text(
                  enemy.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Replace _buildHealthBar with ImageHealthBarWidget
                ImageHealthBarWidget(
                  currentHealth: enemy.health,
                  maxHealth: enemy.maxHealth,
                  width: healthBarWidth,
                  height: healthBarHeight,
                ),
                const SizedBox(height: 2),
                // Keep or remove HP text based on your preference
                Text(
                  'HP: ${enemy.health}/${enemy.maxHealth}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
