class GymConstants {
  static const String appName = 'Gymborn';

  // Premium Membership
  static const double premiumMembershipPrice = 7.99;

  // Stats thresholds for roles
  static const Map<String, Map<String, int>> roleRequirements = {
    'Vanguard': {'STR': 40, 'END': 35},
    'Breaker': {'STR': 50},
    'Windstrider': {'END': 50},
    'Mystic': {'WIS': 45},
    'Sage': {'WIS': 35, 'REC': 30},
    'Architect': {'STR': 30, 'Construction': 30},
    'Verdant': {'REC': 35, 'WIS': 25},
  };

  // Gym check-in details
  static const int freeGymSlots = 5;
  static const int premiumGymSlots = 10;
  static const int gymCheckInProximityInMeters = 10000; // 10 km

  // Premium features
  static const int freeCardSlots = 3;
  static const int premiumCardSlots = 4;
  static const double freeMarketplaceTax = 0.10; // 10%
  static const double premiumMarketplaceTax = 0.03; // 3%

  // Trust system tiers
  static const List<String> trustTiers = ['Verified', 'Standard', 'Flagged'];

  // Skills list
  static const List<String> skillsList = [
    'Smithing',
    'Alchemy',
    'Farming',
    'Runescribing',
    'Cooking',
    'Construction',
  ];

  // Fortress themes
  static const List<String> fortressThemes = [
    'Moonlight Garden',
    'Crystal Lab',
    'Cozy Studio',
  ];

  // Dungeon types by stat
  static const Map<String, String> dungeonTypes = {
    'STR': 'Iron Temple',
    'END': 'Endless Paths',
    'WIS': 'Mystic Meditation Cave',
    'REC': 'Restorative Pools',
  };
}
