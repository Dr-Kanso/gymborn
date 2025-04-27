import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../controllers/battle_controller.dart';
import 'entities/player_component.dart';
import 'entities/enemy_component.dart';
import 'entities/background_component.dart';
import 'components/damage_indicator.dart';
import 'components/victory_message.dart';

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

  BattleGame(this.battleController);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load background
    backgroundComponent = BackgroundComponent();
    add(backgroundComponent);

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
    // Handle victory state
    if (battleController.isVictory && !_victoryProcessed) {
      _victoryProcessed = true;

      // Add some delay before playing victory animation
      Future.delayed(const Duration(milliseconds: 1200), () {
        // Play celebration animation
        playerComponent.playCelebrateAnimation();

        // Show victory message
        add(
          VictoryMessage(message: "VICTORY!\nEnemy Defeated", screenSize: size),
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
