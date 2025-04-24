import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/card.dart';
import '../models/stats.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User collection reference
  CollectionReference get usersCollection => _firestore.collection('users');

  // Cards collection reference
  CollectionReference get cardsCollection =>
      _firestore.collection('synergy_cards');

  // Gyms collection reference
  CollectionReference get gymsCollection => _firestore.collection('gyms');

  // User stream to listen for real-time updates
  Stream<GymBornUser?> userStream(String uid) {
    return usersCollection
        .doc(uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists ? GymBornUser.fromFirestore(snapshot) : null,
        );
  }

  // Get user data
  Future<GymBornUser?> getUserData(String uid) async {
    DocumentSnapshot doc = await usersCollection.doc(uid).get();
    return doc.exists ? GymBornUser.fromFirestore(doc) : null;
  }

  // Update user stats
  Future<void> updateStats(String uid, Stats stats) async {
    return await usersCollection.doc(uid).update({'stats': stats.toMap()});
  }

  // Update user skills
  Future<void> updateSkill(String uid, String skill, int level) async {
    return await usersCollection.doc(uid).update({'skills.$skill': level});
  }

  // Get user's synergy cards
  Future<List<SynergyCard>> getUserCards(String uid) async {
    QuerySnapshot querySnapshot =
        await usersCollection.doc(uid).collection('cards').get();

    return querySnapshot.docs
        .map((doc) => SynergyCard.fromFirestore(doc))
        .toList();
  }

  // Add a card to user's collection
  Future<void> addCardToUser(String uid, String cardId) async {
    DocumentSnapshot cardDoc = await cardsCollection.doc(cardId).get();

    if (cardDoc.exists) {
      await usersCollection
          .doc(uid)
          .collection('cards')
          .doc(cardId)
          .set(cardDoc.data() as Map<String, dynamic>);
    }
  }

  // Add a gym to user's registered gyms
  Future<void> addGymToUser(String uid, String gymId) async {
    await usersCollection.doc(uid).update({
      'gymIds': FieldValue.arrayUnion([gymId]),
    });
  }

  // Remove a gym from user's registered gyms
  Future<void> removeGymFromUser(String uid, String gymId) async {
    await usersCollection.doc(uid).update({
      'gymIds': FieldValue.arrayRemove([gymId]),
    });
  }

  // Mark user as premium
  Future<void> setUserPremium(String uid, bool isPremium) async {
    await usersCollection.doc(uid).update({'isPremium': isPremium});
  }

  // Update user trust level
  Future<void> updateTrustLevel(String uid, String trustLevel) async {
    await usersCollection.doc(uid).update({'trustLevel': trustLevel});
  }

  // Log a workout activity
  Future<void> logWorkout(String uid, Map<String, dynamic> workoutData) async {
    await usersCollection.doc(uid).collection('workouts').add({
      ...workoutData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
