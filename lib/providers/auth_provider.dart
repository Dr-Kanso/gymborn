// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  GymBornUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  GymBornUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuth => _user != null;

  AuthProvider() {
    // Initialize by checking current user
    _initCurrentUser();
  }

  // Initialize app with current user if logged in
  Future<void> _initCurrentUser() async {
    setLoading(true);

    try {
      User? firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        // Get user data from Firestore
        _user = await _firestoreService.getUserData(firebaseUser.uid);
      }
    } catch (error) {
      print('Error initializing user: $error');
      setError('Failed to initialize user data.');
    } finally {
      setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      UserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email, password);

      _user = await _firestoreService.getUserData(userCredential.user!.uid);
      notifyListeners();
      return true;
    } catch (error) {
      String errorMessage = _handleAuthError(error);
      setError(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Register with email, password, and display name
  Future<bool> register(
    String email,
    String password,
    String displayName,
  ) async {
    setLoading(true);
    setError(null);

    try {
      UserCredential userCredential = await _authService
          .registerWithEmailAndPassword(email, password, displayName);

      _user = await _firestoreService.getUserData(userCredential.user!.uid);
      notifyListeners();
      return true;
    } catch (error) {
      String errorMessage = _handleAuthError(error);
      setError(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    setLoading(true);
    setError(null);

    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (error) {
      setError('Failed to sign out.');
    } finally {
      setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    setLoading(true);
    setError(null);

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      if (_user != null) {
        _user = _user!.copyWith(
          displayName: displayName ?? _user!.displayName,
          photoUrl: photoUrl ?? _user!.photoUrl,
        );
      }

      notifyListeners();
      return true;
    } catch (error) {
      setError('Failed to update profile.');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Set user premium status
  Future<bool> setUserPremium(bool isPremium) async {
    setLoading(true);
    setError(null);

    try {
      if (_user != null) {
        await _firestoreService.setUserPremium(_user!.uid, isPremium);
        _user = _user!.copyWith(isPremium: isPremium);
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      setError('Failed to update premium status.');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Helper for setting loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper for setting error message
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Helper to handle Firebase Auth errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'Email is already in use by another account.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return error.message ?? 'An error occurred during authentication.';
      }
    }
    return 'An unexpected error occurred.';
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_user == null) return;

    try {
      _user = await _firestoreService.getUserData(_user!.uid);
      notifyListeners();
    } catch (error) {
      print('Error refreshing user: $error');
    }
  }
}
