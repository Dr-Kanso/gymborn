// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../config/constants.dart';

class Gym {
  final String id;
  final String name;
  final GeoPoint location;
  final String address;
  final String? photoUrl;

  Gym({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    this.photoUrl,
  });

  factory Gym.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Gym(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      address: data['address'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'address': address,
      'photoUrl': photoUrl,
    };
  }

  // Convert GeoPoint to LatLng for OpenStreetMap
  LatLng get latLng => LatLng(location.latitude, location.longitude);
}

class GymCheckinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for gyms
  CollectionReference get gymsCollection => _firestore.collection('gyms');

  // Get all gyms
  Future<List<Gym>> getAllGyms() async {
    QuerySnapshot querySnapshot = await gymsCollection.get();
    return querySnapshot.docs.map((doc) => Gym.fromFirestore(doc)).toList();
  }

  // Get user's registered gyms
  Future<List<Gym>> getUserGyms(List<String> gymIds) async {
    List<Gym> gyms = [];

    for (String gymId in gymIds) {
      DocumentSnapshot doc = await gymsCollection.doc(gymId).get();
      if (doc.exists) {
        gyms.add(Gym.fromFirestore(doc));
      }
    }

    return gyms;
  }

  // Add a new gym
  Future<DocumentReference> addGym(Gym gym) {
    return gymsCollection.add(gym.toMap());
  }

  // Check if user is at a registered gym
  Future<bool> isAtGym(Gym gym) async {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    // Get current position
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting position: $e");
      return false;
    }

    // Calculate distance from gym
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      gym.location.latitude,
      gym.location.longitude,
    );

    // Check if within range
    return distanceInMeters <= GymConstants.gymCheckInProximityInMeters;
  }

  // Record a check-in
  Future<void> recordCheckin(String userId, String gymId) async {
    await _firestore.collection('checkins').add({
      'userId': userId,
      'gymId': gymId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Also update user's last check-in time
    await _firestore.collection('users').doc(userId).update({
      'lastCheckin': {
        'gymId': gymId,
        'timestamp': FieldValue.serverTimestamp(),
      },
    });
  }

  // Get nearby gyms
  Future<List<Gym>> getNearbyGyms(double radiusInMeters) async {
    // Get current position
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting position: $e");
      return [];
    }

    // Get all gyms
    List<Gym> allGyms = await getAllGyms();
    List<Gym> nearbyGyms = [];

    // Filter by distance
    for (Gym gym in allGyms) {
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        gym.location.latitude,
        gym.location.longitude,
      );

      if (distanceInMeters <= radiusInMeters) {
        nearbyGyms.add(gym);
      }
    }

    return nearbyGyms;
  }
}
