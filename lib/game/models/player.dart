import 'dart:math';

class Player {
  final String name;
  int health;
  final int maxHealth;
  int strength = 10; // Default strength
  int experience = 0; // New attribute for experience

  Player({
    required this.name,
    required int initialHealth,
    required this.maxHealth,
  }) : health = initialHealth;

  int calculateDamage() {
    // Base calculation using strength with some randomness
    return strength + Random().nextInt(5);
  }

  void addExperience(int amount) {
    // Implementation depends on your leveling system
    experience += amount;
    // Check for level up if needed
  }

  bool get isDead => health <= 0;

  void takeDamage(int amount) {
    health = (health - amount).clamp(0, maxHealth);
  }
}
