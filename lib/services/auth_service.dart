import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/stats.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the authenticated user stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    // Create user in Firebase Auth
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Add user data to Firestore
    await _createUserDocument(result.user!, displayName);

    return result;
  }

  // Create a user document in Firestore
  Future<void> _createUserDocument(User user, String displayName) async {
    // Update display name in Auth
    await user.updateDisplayName(displayName);

    // Initialize new user data
    GymBornUser newUser = GymBornUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: user.photoURL ?? '',
      stats: Stats(), // Default stats
    );

    // Create document in users collection
    await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Get user data from Firestore
  Future<GymBornUser?> getUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return null;
    }

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (doc.exists) {
      return GymBornUser.fromFirestore(doc);
    }

    return null;
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    if (displayName != null) {
      await user.updateDisplayName(displayName);
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
      });
    }

    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoUrl,
      });
    }
  }
}
