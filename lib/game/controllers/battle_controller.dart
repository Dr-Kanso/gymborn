import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/level.dart';
import '../services/level_service.dart';
import '../factories/enemy_factory.dart';
import 'dart:math';

enum BattleState { idle, playerTurn, enemyTurn, victory, defeat, levelComplete }

class BattleController extends ChangeNotifier {
  Player? player;
  List<Enemy>? _enemies;
  Enemy? _currentEnemy;
  BattleState _state = BattleState.idle;
  int _currentLevel = 1;
  int _currentEnemyIndex = 0;
  final EnemyFactory _enemyFactory = EnemyFactory();
  final Random _random = Random();

  // Animation and state flags
  bool _isPlayerAttacking = false;
  bool _isEnemyAttacking = false;
  bool _playerHurt = false;
  bool _enemyHurt = false;
  bool _playerDying = false;
  bool _enemyDying = false;
  bool _showPlayerDamage = false;
  bool _showEnemyDamage = false;
  bool _showEnemyAttackAnimation = false;
  bool _isAttackInProgress = false;
  int _playerDamageReceived = 0;
  int _enemyDamageReceived = 0;

  // Dungeon level tracking
  int _currentDungeonLevel = 1;
  int _maxDungeonLevels = 5;
  bool _isVictory = false;

  // Getters for battle state
  BattleState get state => _state;
  int get currentLevel => _currentLevel;
  List<Enemy>? get enemies => _enemies;
  bool get playerCanAttack =>
      _state == BattleState.playerTurn && !_isAttackInProgress;
  bool get isAttackInProgress => _isAttackInProgress;

  // Animation state getters and setters
  bool get isPlayerAttacking => _isPlayerAttacking;
  set isPlayerAttacking(bool value) {
    _isPlayerAttacking = value;
    notifyListeners();
  }

  bool get isEnemyAttacking => _isEnemyAttacking;
  set isEnemyAttacking(bool value) {
    _isEnemyAttacking = value;
    notifyListeners();
  }

  bool get playerHurt => _playerHurt;
  set playerHurt(bool value) {
    _playerHurt = value;
    notifyListeners();
  }

  bool get enemyHurt => _enemyHurt;
  set enemyHurt(bool value) {
    _enemyHurt = value;
    notifyListeners();
  }

  bool get playerDying => _playerDying;
  set playerDying(bool value) {
    _playerDying = value;
    notifyListeners();
  }

  bool get enemyDying => _enemyDying;
  set enemyDying(bool value) {
    _enemyDying = value;
    notifyListeners();
  }

  bool get showPlayerDamage => _showPlayerDamage;
  set showPlayerDamage(bool value) {
    _showPlayerDamage = value;
    notifyListeners();
  }

  bool get showEnemyDamage => _showEnemyDamage;
  set showEnemyDamage(bool value) {
    _showEnemyDamage = value;
    notifyListeners();
  }

  bool get showEnemyAttackAnimation => _showEnemyAttackAnimation;
  set showEnemyAttackAnimation(bool value) {
    _showEnemyAttackAnimation = value;
    notifyListeners();
  }

  int get playerDamageReceived => _playerDamageReceived;
  int get enemyDamageReceived => _enemyDamageReceived;

  // Dungeon level getters and setters
  int get currentDungeonLevel => _currentDungeonLevel;
  int get maxDungeonLevels => _maxDungeonLevels; // Add this getter
  set maxDungeonLevels(int value) {
    _maxDungeonLevels = value;
    notifyListeners();
  }

  // Victory state
  bool get isVictory => _isVictory;

  // Getter that ensures we never expose a null enemy during active battle
  Enemy? get currentEnemy {
    if (_state == BattleState.idle || _currentEnemy == null) {
      // Return a placeholder enemy if we're not in battle yet
      // This will only be used for UI rendering, not actual battle logic
      return _currentEnemy; // Can still be null
    }
    return _currentEnemy;
  }

  // Get information about the current level
  Level get level => LevelService.getLevel(_currentLevel);

  // Get total number of available levels
  int get totalLevels => LevelService.levelCount;

  // Initialize a battle with the player and current level
  void initBattle(Player playerCharacter) {
    player = playerCharacter;
    _loadLevel(_currentLevel);

    // Ensure we have a valid enemy before setting to player turn
    if (_enemies != null && _enemies!.isNotEmpty) {
      _currentEnemy = _enemies![0];
      _state = BattleState.playerTurn;
    } else {
      // Create a default enemy if somehow we don't have one
      _currentEnemy = Enemy(
        name: "Training Dummy",
        health: 50,
        maxHealth: 50,
        strength: 5,
      );
      _enemies = [_currentEnemy!];
      _state = BattleState.playerTurn;
    }

    _isVictory = false;
    notifyListeners();
  }

  // Load a specific level and its enemies
  void _loadLevel(int levelNumber) {
    if (levelNumber < 1 || levelNumber > LevelService.levelCount) {
      throw ArgumentError('Invalid level: $levelNumber');
    }

    _currentLevel = levelNumber;
    final level = LevelService.getLevel(levelNumber);
    _enemies = LevelService.generateEnemiesForLevel(level, _enemyFactory);

    // Make sure we have at least one enemy
    if (_enemies == null || _enemies!.isEmpty) {
      // Create a default enemy if the service failed to provide one
      _enemies = [
        Enemy(
          name: level.hasBoss ? "Level Boss" : "Enemy",
          health: 50 * levelNumber,
          maxHealth: 50 * levelNumber,
          strength: 5 * levelNumber,
          isBoss: level.hasBoss,
        ),
      ];
    }

    _currentEnemyIndex = 0;
    _currentEnemy =
        _enemies![0]; // Safe to use ! since we ensured list isn't empty

    notifyListeners();
  }

  // Proceed to the next level
  void nextLevel() {
    if (_currentLevel < LevelService.levelCount) {
      _currentLevel++;
      // Also update the dungeon level to keep them synchronized
      _currentDungeonLevel = _currentLevel;
      _loadLevel(_currentLevel);
      _state = BattleState.playerTurn;
      _isVictory = false;
    } else {
      // Game completed
      _state = BattleState.victory;
      _isVictory = true;
    }
    notifyListeners();
  }

  // Move to the next enemy in the current level
  void nextEnemy() {
    if (_enemies == null || _currentEnemyIndex >= _enemies!.length - 1) {
      _state = BattleState.levelComplete;
      notifyListeners();
      return;
    }

    _currentEnemyIndex++;
    _currentEnemy = _enemies![_currentEnemyIndex];
    _state = BattleState.playerTurn;
    notifyListeners();
  }

  // Process player attack
  void processPlayerAttack() {
    if (_state != BattleState.playerTurn ||
        player == null ||
        _currentEnemy == null) {
      return;
    }

    _isAttackInProgress = true;
    _isPlayerAttacking = true;
    notifyListeners();

    // Add a small delay for attack animation to play
    Future.delayed(const Duration(milliseconds: 500), () {
      // Calculate damage based on player stats
      final damage = player!.calculateDamage();
      _enemyDamageReceived = damage;

      // Apply damage to enemy
      _currentEnemy!.takeDamage(damage);

      // Set flags for UI updates
      _enemyHurt = true;
      _showEnemyDamage = true;

      // Check if enemy is defeated
      if (_currentEnemy!.isDead) {
        _enemyDying = true;

        // Player earns rewards
        player!.addExperience(10 * _currentLevel);

        // Check if there are more enemies
        if (_currentEnemyIndex < (_enemies?.length ?? 0) - 1) {
          // Schedule next enemy
          Future.delayed(const Duration(seconds: 1), () {
            nextEnemy();
            _isAttackInProgress = false;
          });
        } else {
          // Level complete
          _state = BattleState.levelComplete;
          _isVictory = true;

          // Make sure we notify listeners for level transition effects
          notifyListeners();

          _isAttackInProgress = false;
        }
      } else {
        // Enemy's turn
        _state = BattleState.enemyTurn;

        // Schedule enemy attack after a short delay
        Future.delayed(const Duration(milliseconds: 1000), enemyAttack);
      }

      notifyListeners();
    });
  }

  // Enemy attacks the player
  void enemyAttack() {
    if (_state != BattleState.enemyTurn ||
        player == null ||
        _currentEnemy == null) {
      return;
    }

    _isEnemyAttacking = true;
    _showEnemyAttackAnimation = true;
    notifyListeners();

    // Add a small delay for enemy attack animation
    Future.delayed(const Duration(milliseconds: 500), () {
      // Calculate damage
      int damage;
      if (_currentEnemy!.isBoss && _random.nextDouble() < 0.3) {
        damage = (_currentEnemy!.strength * 1.5).round();
      } else {
        damage = (_currentEnemy!.strength + _random.nextInt(5)).clamp(
          1,
          _currentEnemy!.strength * 2,
        );
      }

      // Apply damage to player
      player!.takeDamage(damage);
      _playerDamageReceived = damage;

      // Set flags for UI updates
      _playerHurt = true;
      _showPlayerDamage = true;

      // Check if player is defeated
      if (player!.isDead) {
        _playerDying = true;
        _state = BattleState.defeat;
      } else {
        // Back to player's turn
        _state = BattleState.playerTurn;
      }

      _isAttackInProgress = false;
      _showEnemyAttackAnimation = false;
      notifyListeners();
    });
  }

  // Add playerAttack method to match BattleScreen's call
  void playerAttack() {
    processPlayerAttack();
  }

  // Method for dungeon level progression in Flame game
  void advanceToDungeonLevel(int level) {
    if (level <= _maxDungeonLevels) {
      _currentDungeonLevel = level;
      // Also update the standard level to keep them in sync
      _currentLevel = level;
      // Load the appropriate enemies for this dungeon level
      _loadLevel(level);
      _state = BattleState.playerTurn;
      _isVictory = false;
      notifyListeners();
    }
  }

  // Reset the battle controller
  void reset() {
    _currentLevel = 1;
    _currentDungeonLevel = 1;
    _currentEnemyIndex = 0;
    _state = BattleState.idle;
    _enemies = null;
    _currentEnemy = null;
    _isVictory = false;

    // Reset all animation flags
    _isPlayerAttacking = false;
    _isEnemyAttacking = false;
    _playerHurt = false;
    _enemyHurt = false;
    _playerDying = false;
    _enemyDying = false;
    _showPlayerDamage = false;
    _showEnemyDamage = false;
    _showEnemyAttackAnimation = false;
    _isAttackInProgress = false;
    _playerDamageReceived = 0;
    _enemyDamageReceived = 0;

    notifyListeners();
  }
}
