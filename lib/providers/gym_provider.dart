import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/gym_checkin_status.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:async';
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

  // Store the checkin status for each gym
  final Map<String, GymCheckinStatus> _checkinStatus = {};

  List<Gym> get userGyms => _userGyms;
  List<Gym> get nearbyGyms => _nearbyGyms;
  List<LeisureCenter> get leisureCenters => _leisureCenters;
  Gym? get currentGym => _currentGym;
  bool get isCheckedIn => _isCheckedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter for checkin status
  Map<String, GymCheckinStatus> get checkinStatus => _checkinStatus;

  // Initialize gyms and load saved check-ins
  Future<void> initGyms(User user) async {
    setLoading(true);
    setError(null);

    try {
      // Fetch GymBornUser data first
      GymBornUser? gymBornUser = await _firestoreService.getUserData(user.uid);

      if (gymBornUser != null) {
        _userGyms = await _gymCheckinService.getUserGyms(gymBornUser.gymIds);
        notifyListeners();
      } else {
        setError('Failed to load user data.');
        _userGyms = []; // Clear gyms if user data fails
      }
    } catch (error) {
      setError('Failed to load your gyms: $error');
    } finally {
      setLoading(false);
    }

    // Load saved check-in statuses
    await loadCheckinStatuses(user.uid);

    notifyListeners();
  }

  // Load check-in statuses from SharedPreferences
  Future<void> loadCheckinStatuses(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final checkins = prefs.getString('gym_checkins_$userId');

    if (checkins != null) {
      final Map<String, dynamic> checkinData = json.decode(checkins);

      checkinData.forEach((gymId, data) {
        _checkinStatus[gymId] = GymCheckinStatus.fromJson(data);
      });
    }
  }

  // Save check-in status to SharedPreferences
  Future<void> saveCheckinStatus(GymCheckinStatus status) async {
    // Update in-memory status
    _checkinStatus[status.gymId] = status;

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final userId = status.userId;

    // Get existing data
    final checkins = prefs.getString('gym_checkins_$userId') ?? '{}';
    final Map<String, dynamic> checkinData = json.decode(checkins);

    // Update with new data
    checkinData[status.gymId] = status.toJson();

    // Save back to shared preferences
    await prefs.setString('gym_checkins_$userId', json.encode(checkinData));

    notifyListeners();
  }

  // Check if user can check in to a gym today
  bool canCheckInToday(String userId, String gymId) {
    // If no check-in record exists, user can check in
    if (!_checkinStatus.containsKey(gymId)) return true;

    // Check if the last check-in is still valid for today
    return !_checkinStatus[gymId]!.isValidForToday();
  }

  // Record a check-in for today
  Future<bool> checkIn(String userId, String gymId) async {
    // Only allow check-in if user can check in today
    if (!canCheckInToday(userId, gymId)) return false;

    // Create new check-in status
    final status = GymCheckinStatus(
      userId: userId,
      gymId: gymId,
      lastCheckin: DateTime.now().toUtc(),
    );

    // Save check-in status
    await saveCheckinStatus(status);

    return true;
  }

  // Get formatted time until next check-in is available
  String getTimeUntilNextCheckin(String gymId) {
    if (!_checkinStatus.containsKey(gymId)) return 'Now';

    if (!_checkinStatus[gymId]!.isValidForToday()) return 'Now';

    // Calculate time until midnight GMT
    final now = DateTime.now().toUtc();
    final midnight = DateTime.utc(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '$hours hours, $minutes minutes';
  }

  // Load nearby gyms
  Future<void> loadNearbyGyms(double radiusInMeters) async {
    setLoading(true);
    setError(null);

    try {
      // Add timeout to prevent hanging
      _nearbyGyms = await _gymCheckinService
          .getNearbyGyms(radiusInMeters)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('Nearby gyms request timed out');
              return []; // Return empty list on timeout
            },
          );
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to load nearby gyms: $error');
      setError('Failed to load nearby gyms. Please try again.');
      _nearbyGyms = []; // Ensure we have a valid list even on error
      notifyListeners();
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
