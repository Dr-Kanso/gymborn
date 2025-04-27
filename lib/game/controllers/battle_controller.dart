import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/player.dart';
import '../models/enemy.dart';

class BattleController extends ChangeNotifier {
  final Logger _logger = Logger();
  Player? player;
  Enemy? currentEnemy;
  bool isLoading = false;

  // Animation states
  bool isPlayerAttacking = false;
  bool isEnemyAttacking = false;
  bool showEnemyAttackAnimation = false;

  // Damage display
  int playerDamageReceived = 0;
  int enemyDamageReceived = 0;
  bool showPlayerDamage = false;
  bool showEnemyDamage = false;

  // Add death animation flags
  bool playerDying = false;
  bool enemyDying = false;

  // Victory state
  bool isVictory = false;

  // Dungeon level tracking
  int currentDungeonLevel = 1;
  int maxDungeonLevels = 10;

  void initBattle(Player p, Enemy e) {
    player = p;
    currentEnemy = e;
    isLoading = false;
    _logger.i("Battle initialized with Player and Enemy ${e.name}");
    notifyListeners();
  }

  // Add method to advance to the next dungeon level
  void advanceToDungeonLevel(int level) {
    if (level > maxDungeonLevels) return;

    currentDungeonLevel = level;
    isVictory = false;
    // You could generate new enemies here based on level

    notifyListeners();
  }

  void processPlayerAttack() {
    if (player == null || currentEnemy == null) return;
    if (player!.isDead || currentEnemy!.isDead) return;

    // Reset flags
    isPlayerAttacking = false;
    showEnemyDamage = false;
    enemyDamageReceived = 0;

    // Set flag to trigger animation
    isPlayerAttacking = true;
    notifyListeners();

    // Add a small delay to let animation play before damage calculation
    Future.delayed(Duration(milliseconds: 300), () {
      // Calculate damage
      final damage = player!.calculateDamage();

      // Apply damage
      currentEnemy!.takeDamage(damage);

      // Set damage indicator data
      enemyDamageReceived = damage;
      showEnemyDamage = true;

      // Check if enemy was defeated
      if (currentEnemy!.isDead) {
        enemyDying = true;
        // Set victory state
        isVictory = true;
        _addToBattleLog("Victory! ${currentEnemy!.name} was defeated!");
      } else {
        // Enemy counterattack after a short delay
        Future.delayed(Duration(milliseconds: 500), () {
          _processEnemyAttack();
        });
      }

      notifyListeners();
    });
  }

  void _processEnemyAttack() {
    // Reset damage indicators
    showPlayerDamage = false;
    playerDamageReceived = 0;

    // Show attack animation first
    showEnemyAttackAnimation = true;
    isEnemyAttacking = true;
    notifyListeners();

    // Delay actual damage to match animation timing
    Future.delayed(Duration(milliseconds: 300), () {
      try {
        // Get player health before attack for damage calculation
        final int healthBefore = player!.health;

        // Perform the attack
        currentEnemy!.attackPlayer(player!);

        // Calculate damage dealt for display
        playerDamageReceived = healthBefore - player!.health;
        showPlayerDamage = true;

        // Check for game over
        if (player!.isDead) {
          playerDying = true;
          _handleGameOver(false);
        }

        // Reset animation flag
        showEnemyAttackAnimation = false;
        isEnemyAttacking = false;
        notifyListeners();
      } catch (e, stackTrace) {
        _logger.e(
          "Exception during enemy attack execution",
          error: e,
          stackTrace: stackTrace,
        );
        isEnemyAttacking = false;
        notifyListeners();
      }
    });
  }

  void _handleGameOver(bool playerWon) {
    _logger.i("Game over. Player ${playerWon ? 'won' : 'lost'}");

    // If player won, mark the current level as completed
    if (playerWon && currentDungeonLevel < maxDungeonLevels) {
      // Level complete - could auto-advance or wait for player input
      // For now, we'll just set a flag that the UI can respond to
      isVictory = true;
    }

    notifyListeners();
  }

  // Method to log battle events
  void _addToBattleLog(String message) {
    _logger.i(message);
    // Optionally, add the message to a list for display in the UI
    // battleLogMessages.add(message);
    // notifyListeners(); // If updating UI based on log
  }
}
