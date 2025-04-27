import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../controllers/battle_controller.dart';
import 'entities/player_component.dart';
import 'entities/enemy_component.dart';
import 'entities/background_component.dart';
import 'components/damage_indicator.dart';
import 'components/victory_message.dart';
import 'components/dungeon_level_tracker.dart';

class BattleGame extends FlameGame with TapDetector, HasCollisionDetection {
  final BattleController battleController;

  // Game components
  late PlayerComponent playerComponent;
  late EnemyComponent enemyComponent;
  late BackgroundComponent backgroundComponent;

  // UI text components
  TextComponent? playerHealthText;
  TextComponent? enemyHealthText;
  TextComponent? battleLogText;

  bool get isPlayerDead => battleController.player?.isDead ?? false;
  bool get isEnemyDead => battleController.currentEnemy?.health == 0;

  bool _victoryProcessed = false;

  late DungeonLevelTracker levelTracker;

  BattleGame(this.battleController);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load background
    backgroundComponent = BackgroundComponent();
    add(backgroundComponent);

    // Set maximum dungeon levels to 5
    battleController.maxDungeonLevels = 5;

    // Calculate offset to center the middle (3rd) level
    const int numberOfLevels = 5;
    const double circleRadius = 15;
    const double spacing = circleRadius * 2.5;

    // Position of the middle level (3rd = index 2) from the left of the tracker
    final double middleLevelPosition = ((numberOfLevels - 1) / 2) * spacing;

    // Add level tracker with the 3rd level centered
    levelTracker = DungeonLevelTracker(
      currentLevel: battleController.currentDungeonLevel,
      maxLevels: numberOfLevels,
      // Offset the entire tracker to center the middle level
      position: Vector2(size.x / 2 - middleLevelPosition, 40),
      priority: 100,
      circleRadius: circleRadius,
    );
    add(levelTracker);

    // Load player and enemy sprites
    final player = battleController.player;
    final enemy = battleController.currentEnemy;

    if (player != null) {
      playerComponent = PlayerComponent(player);
      add(playerComponent);
    }

    if (enemy != null) {
      enemyComponent = EnemyComponent(enemy);
      add(enemyComponent);
    }

    // Battle event listeners
    battleController.addListener(_handleBattleStateChange);
  }

  void _handleBattleStateChange() {
    // Update level tracker when dungeon level changes
    if (levelTracker.currentLevel != battleController.currentDungeonLevel) {
      levelTracker.updateLevel(battleController.currentDungeonLevel);
    }

    // Handle victory state
    if (battleController.isVictory && !_victoryProcessed) {
      _victoryProcessed = true;

      // Add some delay before playing victory animation
      Future.delayed(const Duration(milliseconds: 1200), () {
        // Play celebration animation
        playerComponent.playCelebrateAnimation();

        // Show victory message with next level option
        add(
          VictoryMessage(
            message: "VICTORY!\nEnemy Defeated",
            screenSize: size,
            onNextLevel: () {
              battleController.advanceToDungeonLevel(
                battleController.currentDungeonLevel + 1,
              );
              _victoryProcessed = false;
            },
          ),
        );
      });
    }

    // Check for death animations
    if (battleController.playerDying) {
      playerComponent.playDeathAnimation();
      battleController.playerDying = false; // Reset flag
    }

    if (battleController.enemyDying) {
      enemyComponent.playDeathAnimation();
      battleController.enemyDying = false; // Reset flag
    }

    // Check for damage indicators
    if (battleController.showPlayerDamage &&
        battleController.playerDamageReceived > 0) {
      // Show damage numbers above player
      add(
        DamageIndicator(
          amount: battleController.playerDamageReceived,
          startPosition: playerComponent.position.clone()..y -= 50,
        ),
      );

      // Play hurt animation when player takes damage
      if (battleController.playerHurt) {
        playerComponent.playHurtAnimation();
        battleController.playerHurt = false; // Reset the flag
      }

      battleController.showPlayerDamage = false; // Reset flag
    }

    if (battleController.showEnemyDamage &&
        battleController.enemyDamageReceived > 0) {
      // Show damage numbers above enemy
      add(
        DamageIndicator(
          amount: battleController.enemyDamageReceived,
          startPosition: enemyComponent.position.clone()..y -= 50,
        ),
      );

      // Play hurt animation when enemy takes damage
      if (battleController.enemyHurt) {
        enemyComponent.playHurtAnimation();
        battleController.enemyHurt = false; // Reset the flag
      }

      battleController.showEnemyDamage = false; // Reset flag
    }

    // Check for animations
    if (battleController.showEnemyAttackAnimation) {
      enemyComponent.playAttackAnimation();
    }

    // Update health displays
    updateHealthDisplays();
  }

  void updateHealthDisplays() {
    // Since health bars are now in the UI, we don't need to update them here
    // The UI gets health directly from the controller
    // This method can be simplified or removed
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    // Don't process attacks if victory achieved
    if (battleController.isVictory) return;

    // Don't allow player to attack if it's not their turn
    if (!battleController.playerCanAttack) {
      // Optional: could add visual feedback to indicate player must wait
      return;
    }

    if (!isPlayerDead &&
        !isEnemyDead &&
        enemyComponent.containsPoint(info.eventPosition.global)) {
      playerComponent.playAttackAnimation();
      battleController.processPlayerAttack();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (battleController.isPlayerAttacking) {
      playerComponent.playAttackAnimation();
      battleController.isPlayerAttacking =
          false; // Reset flag after triggering animation
    }

    if (battleController.isEnemyAttacking) {
      enemyComponent.playAttackAnimation();
      battleController.isEnemyAttacking =
          false; // Reset flag after triggering animation
    }
  }

  @override
  void onRemove() {
    // Clean up all components properly
    removeAll(children);
    super.onRemove();
  }

  // Add a reset method to properly restart the game
  void reset() {
    removeAll(children);
    // Re-initialize necessary components
    onLoad();
  }
}
