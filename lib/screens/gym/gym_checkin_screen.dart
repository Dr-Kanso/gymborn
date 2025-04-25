import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/location_provider.dart';
import '../../providers/gym_provider.dart';

class GymCheckinScreen extends StatefulWidget {
  const GymCheckinScreen({super.key});

  @override
  State<GymCheckinScreen> createState() => _GymCheckinScreenState();
}

class _GymCheckinScreenState extends State<GymCheckinScreen> {
  bool _isLoadingLocation = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _initLocationAndMap();
  }
  
  Future<void> _initLocationAndMap() async {
    try {
      // Request location permission first
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        // Get location from provider
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        await locationProvider.getCurrentLocation();
        
        if (!mounted) return;
        
        setState(() {
          _isLoadingLocation = false;
        });
      } else {
        // Handle permission denied
        setState(() {
          _isLoadingLocation = false;
          _hasError = true;
          _errorMessage = 'Location permission denied';
        });
      }
    } catch (e) {
      // Handle errors in location fetching
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _hasError = true;
          _errorMessage = 'Failed to get location: ${e.toString()}';
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Check-In'),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your location...'),
          ],
        ),
      );
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoadingLocation = true;
                  _hasError = false;
                });
                _initLocationAndMap();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    // The normal map view with location data
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final currentLocation = locationProvider.currentLocation;
        
        if (currentLocation == null) {
          return const Center(child: Text('Location not available'));
        }
        
        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(currentLocation.latitude, currentLocation.longitude),
                  zoom: 15.0,
                ),
                nonRotatedChildren: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.gymborn',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(currentLocation.latitude, currentLocation.longitude),
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ], children: [],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _attemptGymCheckIn(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Check In', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _attemptGymCheckIn() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      Provider.of<GymProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final currentLocation = locationProvider.currentLocation;
      
      bool success = false;
      if (currentLocation != null) {
        success = true;
      }
      
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No gym found nearby. Please try again when you\'re at a gym.')),
        );
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _hasError = true;
          _errorMessage = 'Failed to check in: ${e.toString()}';
        });
      }
    }
  }
}
