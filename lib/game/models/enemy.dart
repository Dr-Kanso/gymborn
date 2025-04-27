import 'dart:math';
import 'player.dart';

class Enemy {
  final String name;
  int health;
  final int maxHealth;
  final int strength;
  final Random _random = Random();

  Enemy({
    required this.name,
    required this.health,
    required this.maxHealth,
    required this.strength,
  });

  bool get isDead => health <= 0;

  void takeDamage(int amount) {
    health = (health - amount).clamp(0, maxHealth);
  }

  void attackPlayer(Player player) {
    // Simple attack logic with some randomness
    final damage = (strength + _random.nextInt(5)).clamp(1, strength * 2);
    player.takeDamage(damage);
  }
}
