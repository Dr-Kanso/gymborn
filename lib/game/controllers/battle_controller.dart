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

  // Add flags for hurt animations
  bool playerHurt = false;
  bool enemyHurt = false;

  // Add death animation flags
  bool playerDying = false;
  bool enemyDying = false;

  // Victory state
  bool isVictory = false;

  // Dungeon level tracking
  int currentDungeonLevel = 1;
  int maxDungeonLevels = 10;

  // Turn management - player can only attack after enemy has attacked
  bool playerCanAttack = true; // Initially true to allow first attack

  // Add attack cooldown to prevent spam clicking
  bool isAttackInProgress = false;
  DateTime _lastAttackTime = DateTime.now();
  final Duration _attackCooldown = Duration(
    milliseconds: 400,
  ); // 0.5 second cooldown

  void initBattle(Player p, Enemy e) {
    player = p;
    currentEnemy = e;
    isLoading = false;
    playerCanAttack = true; // Reset to allow initial attack
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

    // Check if player is allowed to attack
    if (!playerCanAttack) {
      _logger.i("Player must wait for enemy's turn");
      return;
    }

    // Check if attack is already in progress or on cooldown
    final now = DateTime.now();
    if (isAttackInProgress ||
        now.difference(_lastAttackTime) < _attackCooldown) {
      _logger.i("Attack is on cooldown");
      return;
    }

    // Set attack in progress flag immediately
    isAttackInProgress = true;
    // Disable player attacks immediately
    playerCanAttack = false;

    // Update last attack time
    _lastAttackTime = now;

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

      // Set flag to show enemy hurt animation
      enemyHurt = true;

      // Check if enemy was defeated
      if (currentEnemy!.isDead) {
        enemyDying = true;
        // Set victory state
        isVictory = true;
        _addToBattleLog("Victory! ${currentEnemy!.name} was defeated!");
        // Reset attack flags
        isAttackInProgress = false;
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

        // Set flag to show player hurt animation
        playerHurt = true;

        // Check for game over
        if (player!.isDead) {
          playerDying = true;
          _handleGameOver(false);
        }

        // After enemy's turn, player can attack again after cooldown
        Future.delayed(_attackCooldown, () {
          playerCanAttack = true;
          isAttackInProgress = false;
          notifyListeners();
        });

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

        // Reset attack flags even if there was an error
        Future.delayed(_attackCooldown, () {
          playerCanAttack = true;
          isAttackInProgress = false;
          notifyListeners();
        });
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
