class Player {
  final String name;
  int health;
  final int maxHealth;
  int strength = 10; // Default strength

  Player({
    required this.name,
    required int initialHealth,
    required this.maxHealth,
  }) : health = initialHealth;

  bool get isDead => health <= 0;

  void takeDamage(int amount) {
    health = (health - amount).clamp(0, maxHealth);
  }

  int calculateDamage() {
    // Simple damage calculation based on strength with some randomness
    return strength + (strength * 0.5).round();
  }
}
