// ignore_for_file: deprecated_member_use

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/battle_controller.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../flame/battle_game.dart';
import 'widgets/battle_status_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  BattleGame? _battleGame;

  @override
  void initState() {
    super.initState();

    // Initialize battle if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final battleController = Provider.of<BattleController>(
        context,
        listen: false,
      );

      if (battleController.player == null ||
          battleController.currentEnemy == null) {
        // Create default player and enemy for testing if they don't exist
        final player = Player(
          name: "Player",
          initialHealth: 100,
          maxHealth: 100,
        );
        final enemy = Enemy(
          name: "Goblin",
          health: 50,
          maxHealth: 50,
          strength: 5,
        );
        battleController.initBattle(player, enemy);
      }
    });
  }

  @override
  void dispose() {
    // Properly dispose of the game instance
    _battleGame?.removeFromParent();
    _battleGame = null;
    super.dispose();
  }

  // Add onWillPop handler
  Future<bool> _onWillPop() async {
    // Show a confirmation dialog before leaving the battle
    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave Battle?'),
            content: const Text(
              'Are you sure you want to leave the battle? Progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BattleController>(
      builder: (context, battleController, child) {
        // Initialize the battle game if it hasn't been created yet
        _battleGame ??= BattleGame(battleController);

        return PopScope(
          canPop: false, // Prevent immediate pop
          onPopInvoked: (bool didPop) async {
            if (didPop) {
              return; // Pop already happened or is happening, do nothing.
            }
            // Pop was prevented by canPop: false. Show confirmation dialog.
            final bool shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              // If user confirmed, manually pop the route.
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Battle')),
            body: Column(
              children: [
                // Flame game view (takes most of the screen)
                Expanded(
                  flex: 7,
                  child: GameWidget(
                    game: _battleGame!,
                    loadingBuilder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                    errorBuilder:
                        (context, error) => Center(
                          child: Text(
                            'Error: $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                  ),
                ),

                // New Battle Status Panel
                BattleStatusPanel(controller: battleController),

                // Simplified controls at the bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed:
                        battleController.player?.isDead == true ||
                                !battleController.playerCanAttack ||
                                battleController.isAttackInProgress
                            ? null
                            : () => battleController.processPlayerAttack(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'ATTACK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
