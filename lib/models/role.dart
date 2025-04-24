import 'stats.dart';

enum RoleType {
  vanguard,
  breaker,
  windstrider,
  mystic,
  sage,
  architect,
  verdant,
}

class Role {
  final RoleType type;
  final String name;
  final String description;
  final Map<String, int> statRequirements;
  final List<String> abilities;
  final String icon;

  Role({
    required this.type,
    required this.name,
    required this.description,
    required this.statRequirements,
    required this.abilities,
    required this.icon,
  });

  // Check if user qualifies for this role based on stats
  bool isUnlocked(Stats stats) {
    bool qualifies = true;

    statRequirements.forEach((statName, requiredValue) {
      int userStatValue = 0;

      switch (statName) {
        case 'STR':
          userStatValue = stats.strength;
          break;
        case 'END':
          userStatValue = stats.endurance;
          break;
        case 'WIS':
          userStatValue = stats.wisdom;
          break;
        case 'REC':
          userStatValue = stats.recovery;
          break;
        // Other skills can be added here
      }

      if (userStatValue < requiredValue) {
        qualifies = false;
      }
    });

    return qualifies;
  }

  static List<Role> allRoles = [
    Role(
      type: RoleType.vanguard,
      name: "Vanguard",
      description:
          "A frontline protector with high defense and taunting abilities.",
      statRequirements: {'STR': 40, 'END': 35},
      abilities: ['Shield Wall', 'Taunt', 'Enduring Guard'],
      icon: 'assets/icons/vanguard.png',
    ),
    Role(
      type: RoleType.breaker,
      name: "Breaker",
      description: "A powerful damage dealer focusing on burst damage.",
      statRequirements: {'STR': 50},
      abilities: ['Crushing Blow', 'Staggering Strike', 'Power Surge'],
      icon: 'assets/icons/breaker.png',
    ),
    Role(
      type: RoleType.windstrider,
      name: "Windstrider",
      description: "A swift attacker with high mobility and sustained damage.",
      statRequirements: {'END': 50},
      abilities: ['Swift Strikes', 'Marathon Runner', 'Agile Movement'],
      icon: 'assets/icons/windstrider.png',
    ),
    Role(
      type: RoleType.mystic,
      name: "Mystic",
      description: "A support mage with powerful buffs and utility spells.",
      statRequirements: {'WIS': 45},
      abilities: ['Arcane Shield', 'Mind Enhancement', 'Cosmic Insight'],
      icon: 'assets/icons/mystic.png',
    ),
    Role(
      type: RoleType.sage,
      name: "Sage",
      description: "A healer with restorative abilities and protective spells.",
      statRequirements: {'WIS': 35, 'REC': 30},
      abilities: ['Rejuvenation', 'Healing Wave', 'Protective Barrier'],
      icon: 'assets/icons/sage.png',
    ),
    Role(
      type: RoleType.architect,
      name: "Architect",
      description: "An engineer who builds structures and support items.",
      statRequirements: {'STR': 30, 'Construction': 30},
      abilities: ['Fortification', 'Construct Turret', 'Resource Gathering'],
      icon: 'assets/icons/architect.png',
    ),
    Role(
      type: RoleType.verdant,
      name: "Verdant",
      description: "A nature-attuned healer who specializes in debuffs.",
      statRequirements: {'REC': 35, 'WIS': 25},
      abilities: ['Nature\'s Touch', 'Weakening Pollen', 'Rejuvenating Growth'],
      icon: 'assets/icons/verdant.png',
    ),
  ];
}
