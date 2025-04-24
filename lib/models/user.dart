import 'package:cloud_firestore/cloud_firestore.dart';
import 'stats.dart';

class GymBornUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isPremium;
  final String trustLevel; // Verified, Standard, Flagged
  final List<String> availableRoles;
  final Stats stats;
  final List<String> gymIds;
  final Map<String, int> skills;

  GymBornUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.isPremium = false,
    this.trustLevel = 'Standard',
    this.availableRoles = const [],
    required this.stats,
    this.gymIds = const [],
    this.skills = const {},
  });

  factory GymBornUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GymBornUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      isPremium: data['isPremium'] ?? false,
      trustLevel: data['trustLevel'] ?? 'Standard',
      availableRoles: List<String>.from(data['availableRoles'] ?? []),
      stats: Stats.fromMap(data['stats'] ?? {}),
      gymIds: List<String>.from(data['gymIds'] ?? []),
      skills: Map<String, int>.from(data['skills'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isPremium': isPremium,
      'trustLevel': trustLevel,
      'availableRoles': availableRoles,
      'stats': stats.toMap(),
      'gymIds': gymIds,
      'skills': skills,
    };
  }

  GymBornUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isPremium,
    String? trustLevel,
    List<String>? availableRoles,
    Stats? stats,
    List<String>? gymIds,
    Map<String, int>? skills,
  }) {
    return GymBornUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      trustLevel: trustLevel ?? this.trustLevel,
      availableRoles: availableRoles ?? this.availableRoles,
      stats: stats ?? this.stats,
      gymIds: gymIds ?? this.gymIds,
      skills: skills ?? this.skills,
    );
  }
}
