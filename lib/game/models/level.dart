class Level {
  final int levelNumber;
  final String name;
  final String description;
  final int enemyCount;
  final double difficultyMultiplier;
  final bool hasBoss;

  const Level({
    required this.levelNumber,
    required this.name,
    required this.description,
    required this.enemyCount,
    required this.difficultyMultiplier,
    this.hasBoss = false,
  });

  bool get isBossLevel => hasBoss;

  @override
  String toString() => name;
}
