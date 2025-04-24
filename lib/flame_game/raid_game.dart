import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../themes/theme.dart';
import '../models/role.dart';

// This is a placeholder implementation that will be expanded later
// with actual multiplayer raid mechanics using the Flame engine

class RaidGame extends FlameGame with TapDetector, HasCollisionDetection {
  late final String raidName;
  late final Color raidColor;
  late final int raidLevel;
  late final RoleType playerRole;

  late final TextComponent titleComponent;
  late final List<SpriteComponent> playerComponents = [];
  late final SpriteComponent bossComponent;

  bool gameOver = false;
  bool victory = false;
  int bossHealth = 1000;
  Map<RoleType, int> playerHealthMap = {};

  // Simulated multiplayer players
  final List<Map<String, dynamic>> participants;

  RaidGame({
    required this.raidName,
    required this.raidColor,
    required this.raidLevel,
    required this.playerRole,
    required this.participants,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set up background
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = raidColor.withAlpha((0.2 * 255).round()),
    );
    add(background);

    // Title text
    titleComponent = TextComponent(
      text: raidName,
      textRenderer: TextPaint(
        style: TextStyle(
          color: raidColor,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    titleComponent.position = Vector2(
      size.x / 2 - titleComponent.width / 2,
      50,
    );
    add(titleComponent);

    // Boss component
    bossComponent =
        RectangleComponent(
              size: Vector2(120, 150),
              position: Vector2(size.x / 2 - 60, size.y / 4 - 75),
              paint: Paint()..color = Colors.purple,
            )
            as SpriteComponent;
    add(bossComponent);

    // Add boss health bar
    _addBossHealthBar();

    // Player components (including the actual player)
    final List<Map<String, dynamic>> allParticipants = [
      ...participants,
      {
        'name': 'You',
        'role': _getRoleStringFromType(playerRole),
        'level': 20, // Placeholder player level
      },
    ];

    // Position players in a semi-circle at the bottom
    final int participantCount = allParticipants.length;
    final double radius = size.x * 0.4;
    final double centerX = size.x / 2;
    final double centerY = size.y * 0.75;

    for (int i = 0; i < participantCount; i++) {
      final participant = allParticipants[i];
      final double angle = -3.14 / 2 + (3.14 * i / (participantCount - 1));
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);

      final Color playerColor = _getRoleColor(participant['role']);

      final playerComponent = RectangleComponent(
        size: Vector2(50, 80),
        position: Vector2(x - 25, y - 40),
        paint: Paint()..color = playerColor,
      );

      // Add player name
      final nameTag = TextComponent(
        text: participant['name'],
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      );
      nameTag.position = Vector2(
        playerComponent.position.x +
            playerComponent.size.x / 2 -
            nameTag.width / 2,
        playerComponent.position.y - 20,
      );

      // Initialize health for this player
      final roleType = _getRoleTypeFromString(participant['role']);
      if (roleType != null) {
        playerHealthMap[roleType] = 100;
      }

      add(playerComponent);
      add(nameTag);
      playerComponents.add(playerComponent as SpriteComponent);
    }

    // Instructions
    final instructionsComponent = TextComponent(
      text: 'Tap to use role ability',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );
    instructionsComponent.position = Vector2(
      size.x / 2 - instructionsComponent.width / 2,
      size.y - 50,
    );
    add(instructionsComponent);
  }

  void _addBossHealthBar() {
    final bossHealthBarBackground = RectangleComponent(
      size: Vector2(size.x * 0.8, 20),
      position: Vector2(size.x * 0.1, 100),
      paint: Paint()..color = Colors.grey.withAlpha((0.3 * 255).round()),
    );
    add(bossHealthBarBackground);

    final bossHealthBarFill = RectangleComponent(
      size: Vector2(size.x * 0.8, 20),
      position: Vector2(size.x * 0.1, 100),
      paint: Paint()..color = Colors.red,
    );
    add(bossHealthBarFill);
  }

  @override
  void onTap() {
    if (gameOver) return;

    // Apply damage based on role
    int damage = 0;
    switch (playerRole) {
      case RoleType.vanguard:
        damage = 20;
        break;
      case RoleType.breaker:
        damage = 50;
        break;
      case RoleType.windstrider:
        damage = 30;
        break;
      case RoleType.mystic:
        damage = 15;
        break;
      case RoleType.sage:
        damage = 10;
        break;
      case RoleType.architect:
        damage = 25;
        break;
      case RoleType.verdant:
        damage = 20;
        break;
    }

    bossHealth -= damage;
    if (bossHealth <= 0) {
      bossHealth = 0;
      gameOver = true;
      victory = true;
      _showGameOverText();
    }

    // Boss counter-attack
    Future.delayed(const Duration(milliseconds: 500), () {
      if (gameOver) return;

      // Random target selection from players
      playerHealthMap.forEach((role, health) {
        playerHealthMap[role] = health - 10;

        if (role == playerRole && playerHealthMap[role]! <= 0) {
          gameOver = true;
          victory = false;
          _showGameOverText();
        }
      });
    });
  }

  void _showGameOverText() {
    final gameOverComponent = TextComponent(
      text: victory ? 'Raid Victory!' : 'Raid Failed!',
      textRenderer: TextPaint(
        style: TextStyle(
          color: victory ? Colors.green : Colors.red,
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    gameOverComponent.position = Vector2(
      size.x / 2 - gameOverComponent.width / 2,
      size.y / 2 - gameOverComponent.height / 2,
    );
    add(gameOverComponent);
  }

  Color _getRoleColor(String roleStr) {
    switch (roleStr) {
      case 'Vanguard':
        return kStrColor.withAlpha((0.8 * 255).round());
      case 'Breaker':
        return kStrColor;
      case 'Windstrider':
        return kEndColor;
      case 'Mystic':
        return kWisColor;
      case 'Sage':
        return kWisColor.withAlpha((0.8 * 255).round());
      case 'Architect':
        return kPrimaryColor;
      case 'Verdant':
        return kRecColor;
      default:
        return Colors.grey;
    }
  }

  RoleType? _getRoleTypeFromString(String roleStr) {
    switch (roleStr) {
      case 'Vanguard':
        return RoleType.vanguard;
      case 'Breaker':
        return RoleType.breaker;
      case 'Windstrider':
        return RoleType.windstrider;
      case 'Mystic':
        return RoleType.mystic;
      case 'Sage':
        return RoleType.sage;
      case 'Architect':
        return RoleType.architect;
      case 'Verdant':
        return RoleType.verdant;
      default:
        return null;
    }
  }

  String _getRoleStringFromType(RoleType roleType) {
    switch (roleType) {
      case RoleType.vanguard:
        return 'Vanguard';
      case RoleType.breaker:
        return 'Breaker';
      case RoleType.windstrider:
        return 'Windstrider';
      case RoleType.mystic:
        return 'Mystic';
      case RoleType.sage:
        return 'Sage';
      case RoleType.architect:
        return 'Architect';
      case RoleType.verdant:
        return 'Verdant';
    }
  }
}

// Widget that wraps the Flame game for Flutter integration
class RaidGameWidget extends StatelessWidget {
  final String raidName;
  final Color raidColor;
  final int raidLevel;
  final RoleType playerRole;
  final List<Map<String, dynamic>> participants;
  final VoidCallback onGameOver;

  const RaidGameWidget({
    super.key,
    required this.raidName,
    required this.raidColor,
    required this.raidLevel,
    required this.playerRole,
    required this.participants,
    required this.onGameOver,
  });

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: RaidGame(
        raidName: raidName,
        raidColor: raidColor,
        raidLevel: raidLevel,
        playerRole: playerRole,
        participants: participants,
      ),
      loadingBuilder:
          (context) => const Center(child: CircularProgressIndicator()),
      errorBuilder:
          (context, error) => Center(
            child: Text(
              'An error occurred: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
    );
  }
}
