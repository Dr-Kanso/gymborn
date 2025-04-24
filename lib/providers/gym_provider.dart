import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import '../models/user.dart';
import '../services/gym_checkin_service.dart';
import '../services/firestore_service.dart';
import '../config/constants.dart';

class LeisureCenter {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  LeisureCenter({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  // Convert to Gym model
  Gym toGym() {
    return Gym(
      id: id,
      name: name,
      address: address ?? 'Leisure Center',
      location: GeoPoint(latitude, longitude),
    );
  }
}

class GymProvider with ChangeNotifier {
  final GymCheckinService _gymCheckinService = GymCheckinService();
  final FirestoreService _firestoreService = FirestoreService();

  // Debounce mechanism
  Timer? _debounceTimer;
  bool _updatePending = false;

  List<Gym> _userGyms = [];
  List<Gym> _nearbyGyms = [];
  List<LeisureCenter> _leisureCenters = [];
  Gym? _currentGym;
  bool _isCheckedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<Gym> get userGyms => _userGyms;
  List<Gym> get nearbyGyms => _nearbyGyms;
  List<LeisureCenter> get leisureCenters => _leisureCenters;
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

  // Load nearby leisure centers
  Future<void> loadLeisureCenters(
    double lat,
    double lon,
    double radiusInMeters,
  ) async {
    setLoading(true);
    setError(null);

    try {
      // Calculate bounding box (rough estimate)
      double approxLatDegrees = radiusInMeters / 111000; // 111km ~ 1 degree lat
      double approxLonDegrees = radiusInMeters / (111000 * cos(lat * pi / 180));

      double minLat = lat - approxLatDegrees;
      double maxLat = lat + approxLatDegrees;
      double minLon = lon - approxLonDegrees;
      double maxLon = lon + approxLonDegrees;

      // Create Overpass API query to find leisure centers
      String query = '''
      [out:json];
      (
        node["leisure"="fitness_centre"]($minLat,$minLon,$maxLat,$maxLon);
        way["leisure"="fitness_centre"]($minLat,$minLon,$maxLat,$maxLon);
        node["leisure"="sports_centre"]($minLat,$minLon,$maxLat,$maxLon);
        way["leisure"="sports_centre"]($minLat,$minLon,$maxLat,$maxLon);
      );
      out center;
      ''';

      // Encode query for URL
      String encodedQuery = Uri.encodeComponent(query);
      var url = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=$encodedQuery',
      );

      // Make request to Overpass API
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<LeisureCenter> centers = [];

        if (data['elements'] != null) {
          for (var element in data['elements']) {
            double elementLat;
            double elementLon;

            // Handle different element types
            if (element['type'] == 'node') {
              elementLat = element['lat'];
              elementLon = element['lon'];
            } else if (element['type'] == 'way' && element['center'] != null) {
              elementLat = element['center']['lat'];
              elementLon = element['center']['lon'];
            } else {
              continue; // Skip elements we can't map
            }

            String name = element['tags']?['name'] ?? 'Unnamed Leisure Center';

            centers.add(
              LeisureCenter(
                id: 'osm_${element['type']}_${element['id']}',
                name: name,
                latitude: elementLat,
                longitude: elementLon,
                address: element['tags']?['addr:street'] ?? '',
              ),
            );
          }
        }

        _leisureCenters = centers;
      }

      notifyListeners();
    } catch (error) {
      setError('Failed to load leisure centers: $error');
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
