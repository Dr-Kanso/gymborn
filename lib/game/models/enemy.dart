import 'dart:math';
import 'player.dart';

class Enemy {
  final String id;
  final String name;
  int health;
  final int maxHealth;
  final int strength;
  final bool isBoss;
  final Random _random = Random();

  Enemy({
    required this.name,
    required this.health,
    required this.maxHealth,
    required this.strength,
    this.isBoss = false,
    this.id = '',
  });

  bool get isDead => health <= 0;

  void takeDamage(int amount) {
    health = (health - amount).clamp(0, maxHealth);
  }

  void attackPlayer(Player player) {
    // Simple attack logic with some randomness
    int damage;
    if (isBoss && _random.nextDouble() < 0.3) {
      // Special boss attack with extra damage
      damage = (strength * 1.5).round();
    } else {
      damage = (strength + _random.nextInt(5)).clamp(1, strength * 2);
    }
    player.takeDamage(damage);
  }
}
