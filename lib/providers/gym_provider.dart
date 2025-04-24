import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user.dart';
import '../services/gym_checkin_service.dart';
import '../services/firestore_service.dart';
import '../config/constants.dart';

class GymProvider with ChangeNotifier {
  final GymCheckinService _gymCheckinService = GymCheckinService();
  final FirestoreService _firestoreService = FirestoreService();

  // Debounce mechanism
  Timer? _debounceTimer;
  bool _updatePending = false;

  List<Gym> _userGyms = [];
  List<Gym> _nearbyGyms = [];
  Gym? _currentGym;
  bool _isCheckedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<Gym> get userGyms => _userGyms;
  List<Gym> get nearbyGyms => _nearbyGyms;
  Gym? get currentGym => _currentGym;
  bool get isCheckedIn => _isCheckedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize gym data for user
  Future<void> initGyms(GymBornUser user) async {
    setLoading(true);
    setError(null);

    try {
      _userGyms = await _gymCheckinService.getUserGyms(user.gymIds);
      notifyListeners();
    } catch (error) {
      setError('Failed to load your gyms: $error');
    } finally {
      setLoading(false);
    }
  }

  // Load nearby gyms
  Future<void> loadNearbyGyms(double radiusInMeters) async {
    setLoading(true);
    setError(null);

    try {
      _nearbyGyms = await _gymCheckinService.getNearbyGyms(radiusInMeters);
      notifyListeners();
    } catch (error) {
      setError('Failed to load nearby gyms: $error');
    } finally {
      setLoading(false);
    }
  }

  // Check if user is at a gym
  Future<bool> checkIfAtGym(Gym gym) async {
    setLoading(true);
    setError(null);

    try {
      bool isAtGym = await _gymCheckinService.isAtGym(gym);
      if (isAtGym) {
        _currentGym = gym;
      }
      notifyListeners();
      return isAtGym;
    } catch (error) {
      setError('Failed to check gym location: $error');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Check-in to gym
  Future<bool> checkInToGym(String userId, Gym gym) async {
    setLoading(true);
    setError(null);

    try {
      // Verify user is at the gym
      bool isAtGym = await _gymCheckinService.isAtGym(gym);

      if (!isAtGym) {
        setError('You must be at the gym to check in');
        return false;
      }

      // Record the check-in
      await _gymCheckinService.recordCheckin(userId, gym.id);

      // Update state
      _currentGym = gym;
      _isCheckedIn = true;

      // Add gym to user's gyms if not already added
      if (!_userGyms.any((userGym) => userGym.id == gym.id)) {
        // Check if user can add more gyms
        GymBornUser? user = await _firestoreService.getUserData(userId);

        if (user == null) {
          setError('User data not found');
          return false;
        }

        int maxGyms =
            user.isPremium
                ? GymConstants.premiumGymSlots
                : GymConstants.freeGymSlots;

        if (user.gymIds.length >= maxGyms) {
          setError('You\'ve reached your maximum number of registered gyms');
          return false;
        }

        await _firestoreService.addGymToUser(userId, gym.id);
        _userGyms.add(gym);
      }

      notifyListeners();
      return true;
    } catch (error) {
      setError('Failed to check in: $error');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Check out from gym
  void checkOutFromGym() {
    _currentGym = null;
    _isCheckedIn = false;
    notifyListeners();
  }

  // Add new gym
  Future<bool> addNewGym(Gym gym, String userId) async {
    setLoading(true);
    setError(null);

    try {
      // Add gym to Firestore
      final docRef = await _gymCheckinService.addGym(gym);

      // Get the newly created gym with generated ID
      Gym newGym = gym;

      // Add gym to user's gyms
      await _firestoreService.addGymToUser(userId, docRef.id);

      // Update local list
      _userGyms.add(newGym);
      notifyListeners();
      return true;
    } catch (error) {
      setError('Failed to add gym: $error');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Remove gym from user's list
  Future<bool> removeGym(String userId, String gymId) async {
    setLoading(true);
    setError(null);

    try {
      await _firestoreService.removeGymFromUser(userId, gymId);

      // Make all state updates before notification
      _userGyms.removeWhere((gym) => gym.id == gymId);

      if (_currentGym != null && _currentGym!.id == gymId) {
        _currentGym = null;
        _isCheckedIn = false;
      }

      _safeNotify();
      return true;
    } catch (error) {
      setError('Failed to remove gym: $error');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Safe notify method with debounce
  void _safeNotify() {
    // Cancel any pending notifications
    _debounceTimer?.cancel();

    // Set a flag to indicate an update is pending
    _updatePending = true;

    // Schedule notification after a short delay to batch rapid updates
    _debounceTimer = Timer(const Duration(milliseconds: 10), () {
      if (_updatePending) {
        _updatePending = false;
        // Use microtask to ensure notify happens after build phase
        Future.microtask(() => notifyListeners());
      }
    });
  }

  // Helper for setting loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotify();
    }
  }

  // Helper for setting error message
  void setError(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      _safeNotify();
    }
  }
}
