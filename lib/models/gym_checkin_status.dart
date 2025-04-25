class GymCheckinStatus {
  final String userId;
  final String gymId;
  final DateTime lastCheckin;

  GymCheckinStatus({
    required this.userId,
    required this.gymId,
    required this.lastCheckin,
  });

  // Create from JSON for SharedPreferences storage
  factory GymCheckinStatus.fromJson(Map<String, dynamic> json) {
    return GymCheckinStatus(
      userId: json['userId'],
      gymId: json['gymId'],
      lastCheckin: DateTime.parse(json['lastCheckin']),
    );
  }

  // Convert to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'gymId': gymId,
      'lastCheckin': lastCheckin.toIso8601String(),
    };
  }

  // Check if the check-in is still valid (same day in GMT)
  bool isValidForToday() {
    final now = DateTime.now().toUtc();
    final lastCheckinUtc = lastCheckin.toUtc();

    // Check if the dates are the same (ignoring time)
    return now.year == lastCheckinUtc.year &&
        now.month == lastCheckinUtc.month &&
        now.day == lastCheckinUtc.day;
  }
}
