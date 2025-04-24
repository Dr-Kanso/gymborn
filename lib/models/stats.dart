class Stats {
  final int strength; // STR - Resistance training
  final int endurance; // END - Cardio
  final int wisdom; // WIS - Meditation/Yoga
  final int recovery; // REC - Rest/Sleep tracking

  Stats({
    this.strength = 0,
    this.endurance = 0,
    this.wisdom = 0,
    this.recovery = 0,
  });

  factory Stats.fromMap(Map<String, dynamic> data) {
    return Stats(
      strength: data['strength'] ?? 0,
      endurance: data['endurance'] ?? 0,
      wisdom: data['wisdom'] ?? 0,
      recovery: data['recovery'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'strength': strength,
      'endurance': endurance,
      'wisdom': wisdom,
      'recovery': recovery,
    };
  }

  Stats copyWith({int? strength, int? endurance, int? wisdom, int? recovery}) {
    return Stats(
      strength: strength ?? this.strength,
      endurance: endurance ?? this.endurance,
      wisdom: wisdom ?? this.wisdom,
      recovery: recovery ?? this.recovery,
    );
  }

  // Calculate overall level
  int get totalLevel => strength + endurance + wisdom + recovery;

  // Get formatted stat map
  Map<String, int> get statMap => {
    'STR': strength,
    'END': endurance,
    'WIS': wisdom,
    'REC': recovery,
  };
}
