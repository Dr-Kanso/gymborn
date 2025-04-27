import 'package:flutter/material.dart';
import '../../controllers/battle_controller.dart';

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
                _buildHealthBar(
                  current: player.health,
                  max: player.maxHealth,
                  color: Colors.green,
                ),
                const SizedBox(height: 2),
                Text(
                  'HP: ${player.health}/${player.maxHealth}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          // VS indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Enemy stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                _buildHealthBar(
                  current: enemy.health,
                  max: enemy.maxHealth,
                  color: Colors.red,
                  reverse: true,
                ),
                const SizedBox(height: 2),
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

  Widget _buildHealthBar({
    required int current,
    required int max,
    required Color color,
    bool reverse = false,
  }) {
    final percentage = (current / max).clamp(0.0, 1.0);

    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey.shade800,
      ),
      child: Align(
        alignment: reverse ? Alignment.centerRight : Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: percentage,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: color,
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withAlpha(179), // 0.7 * 255 ≈ 179
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
