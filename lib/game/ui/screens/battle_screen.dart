import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/battle_controller.dart';
import '../widgets/battle_status_panel.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  @override
  Widget build(BuildContext context) {
    final battleController = Provider.of<BattleController>(context);
    final currentLevel = battleController.level;
    final enemy = battleController.currentEnemy;
    final battleState = battleController.state;

    // Show loading UI if battle isn't ready yet
    if (enemy == null) {
      return Scaffold(
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          title: const Text('Preparing Battle...'),
          backgroundColor: Colors.blueGrey[800],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text(
          'Level ${battleController.currentLevel}: ${currentLevel.name}',
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Column(
        children: [
          // Level info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey[800],
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentLevel.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  enemy.isBoss
                      ? '⚠️ Boss Fight!'
                      : 'Enemy ${(battleController.enemies?.indexOf(enemy) ?? 0) + 1} of ${battleController.enemies?.length ?? 0}',
                  style: TextStyle(
                    color: enemy.isBoss ? Colors.red[300] : Colors.white,
                    fontWeight:
                        enemy.isBoss ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Battle status panel
          BattleStatusPanel(controller: battleController),

          // Enemy visualization
          Expanded(
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: enemy.isBoss ? Colors.red[700] : Colors.blue[700],
                  borderRadius: BorderRadius.circular(enemy.isBoss ? 0 : 100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(
                        127,
                      ), // Using withAlpha instead of withValues
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    enemy.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey[800],
            child: _buildActionButtons(battleController, battleState),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BattleController controller, BattleState state) {
    switch (state) {
      case BattleState.playerTurn:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => controller.playerAttack(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Attack', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                // For future implementation of special abilities
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Ability', style: TextStyle(fontSize: 18)),
            ),
          ],
        );

      case BattleState.enemyTurn:
        return const Center(
          child: Text(
            'Enemy is attacking...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );

      case BattleState.victory:
        return Center(
          child: Column(
            children: [
              const Text(
                'Game Complete! You conquered all levels!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.reset(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Play Again'),
              ),
            ],
          ),
        );

      case BattleState.defeat:
        return Center(
          child: Column(
            children: [
              const Text(
                'You have been defeated!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.reset(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Try Again'),
              ),
            ],
          ),
        );

      case BattleState.levelComplete:
        return Center(
          child: Column(
            children: [
              Text(
                controller.currentLevel < controller.totalLevels
                    ? 'Level Complete!'
                    : 'You beat the final boss!',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    controller.currentLevel < controller.totalLevels
                        ? () => controller.nextLevel()
                        : () => controller.reset(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  controller.currentLevel < controller.totalLevels
                      ? 'Next Level'
                      : 'New Game',
                ),
              ),
            ],
          ),
        );

      case BattleState.idle:
        return const Center(child: CircularProgressIndicator());
    }
  }
}
