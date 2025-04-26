// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../components/custom_button.dart';
import '../../components/gym_tile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_checkin_service.dart';
import '../../themes/theme.dart';
import '../../config/constants.dart';
import '../../widgets/osm_map.dart';

class GymCheckinScreen extends StatefulWidget {
  const GymCheckinScreen({super.key});

  @override
  State<GymCheckinScreen> createState() => _GymCheckinScreenState();
}

class _GymCheckinScreenState extends State<GymCheckinScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  MapController? _mapController;
  Gym? _selectedGym;
  Position? _currentPosition;
  List<Marker> _markers = [];
  LeisureCenter? _selectedLeisureCenter;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentLocation();
    _loadNearbyGyms();

    // Add listener to refresh markers when tab changes
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Listen for tab changes to update markers
  void _handleTabChange() {
    if (_tabController.index == 1 && !_isLoading && _currentPosition != null) {
      // When switching to Find Gyms tab, refresh the data
      _refreshGymData();
    }
  }

  // Refresh gym data and markers
  Future<void> _refreshGymData() async {
    setState(() {
      _isLoading = true;
    });

    await _loadNearbyGyms();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable them.',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });

        // Provide alternative with default location to avoid app being stuck
        _handleLocationFallback();
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle denied permissions with fallback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using default location. Location access denied.'),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          _handleLocationFallback();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Use fallback for permanently denied permissions
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Using default location. Please enable location in settings for better accuracy.',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        _handleLocationFallback();
        return;
      }

      // Add timeout to prevent infinite waiting
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      ).catchError((error) {
        debugPrint('Geolocator error: $error');
        _handleLocationFallback();
        return Position(
          longitude: 0,
          latitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.move(LatLng(position.latitude, position.longitude), 14);
        _updateMarkers();
      }
    } catch (e) {
      debugPrint('Error getting position: $e');
      setState(() {
        _isLoading = false;
      });

      // Handle error with fallback
      _handleLocationFallback();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Using default location. Error: ${e.toString().split('\n').first}',
          ),
        ),
      );
    }
  }

  void _handleLocationFallback() {
    // Default to a fallback position (you could use user's last known position or a city center)
    final fallbackPosition = Position(
      longitude: 0.0,
      latitude: 51.5074, // London coordinates as fallback
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    setState(() {
      _currentPosition = fallbackPosition;
    });

    if (_mapController != null) {
      _mapController!.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        14,
      );
    }

    // Still try to load nearby gyms with default location
    _loadNearbyGyms();
  }

  Future<void> _loadNearbyGyms() async {
    if (_currentPosition == null) {
      debugPrint('Cannot load nearby gyms: Position is null');
      return;
    }

    final gymProvider = Provider.of<GymProvider>(context, listen: false);

    try {
      await gymProvider.loadNearbyGyms(5000); // 5km radius
      debugPrint('Loaded ${gymProvider.nearbyGyms.length} nearby gyms');

      // Load leisure centers
      await gymProvider.loadLeisureCenters(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        5000, // 5km radius
      );

      debugPrint('Loaded ${gymProvider.leisureCenters.length} leisure centers');

      // Force update markers after loading
      _updateMarkers();
    } catch (e) {
      debugPrint('Error loading nearby gyms or leisure centers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load nearby locations: ${e.toString().split('\n').first}',
          ),
        ),
      );
    }
  }

  void _updateMarkers() {
    if (_currentPosition == null) return;

    final gymProvider = Provider.of<GymProvider>(context, listen: false);
    List<Marker> markers = [];

    // Current location marker
    markers.add(
      Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha((0.7 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_history,
            color: Colors.white,
            size: 40.0,
          ),
        ),
      ),
    );

    // User's registered gyms with improved visibility
    for (var gym in gymProvider.userGyms) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: gym.latLng,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGym = gym;
                _selectedLeisureCenter = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha((0.7 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ),
        ),
      );
    }

    // Nearby gyms with improved visibility
    for (var gym in gymProvider.nearbyGyms) {
      // Skip if already in user gyms
      if (gymProvider.userGyms.any((userGym) => userGym.id == gym.id)) continue;

      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: gym.latLng,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGym = gym;
                _selectedLeisureCenter = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((0.7 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ),
        ),
      );
    }

    // Leisure centers with improved visibility
    if (gymProvider.leisureCenters.isEmpty) {
      debugPrint('Warning: No leisure centers to display on map');
    }

    for (var center in gymProvider.leisureCenters) {
      // Skip if this center is already a registered gym - using safer comparison
      bool alreadyRegistered = false;
      for (var gym in gymProvider.userGyms) {
        if (gym.id == center.id ||
            (gym.name == center.name &&
                gym.latLng.latitude.toStringAsFixed(4) ==
                    center.latitude.toStringAsFixed(4) &&
                gym.latLng.longitude.toStringAsFixed(4) ==
                    center.longitude.toStringAsFixed(4))) {
          alreadyRegistered = true;
          break;
        }
      }

      if (alreadyRegistered) continue;

      markers.add(
        Marker(
          width: 50.0, // Increased from 40.0 for better visibility
          height: 50.0, // Increased from 40.0 for better visibility
          point: LatLng(center.latitude, center.longitude),
          child: GestureDetector(
            onTap: () {
              debugPrint('Leisure center tapped: ${center.name}');
              setState(() {
                _selectedLeisureCenter = center;
                _selectedGym = null; // Clear any selected gym
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.9 * 255).round()),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2), // Added border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.3 * 255).round()),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ),
        ),
      );
    }

    debugPrint('Total markers on map: ${markers.length}');
    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gymProvider = Provider.of<GymProvider>(context);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Gym Check-In'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kLightTextColor,
          indicatorColor: kPrimaryColor,
          tabs: const [Tab(text: 'Your Gyms'), Tab(text: 'Find Gyms')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildYourGymsTab(authProvider.user!.uid, gymProvider),
          _buildFindGymsTab(authProvider.user!.uid, gymProvider),
        ],
      ),
    );
  }

  Widget _buildYourGymsTab(String userId, GymProvider gymProvider) {
    final bool isPremium = Provider.of<AuthProvider>(context).user!.isPremium;
    final int maxGyms =
        isPremium ? GymConstants.premiumGymSlots : GymConstants.freeGymSlots;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: kPrimaryColor.withAlpha((0.1 * 255).round()),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can register up to $maxGyms gyms. Check-in to earn daily rewards and access dungeons!',
                  style: TextStyle(color: kTextColor, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: gymProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : gymProvider.userGyms.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: gymProvider.userGyms.length,
                      itemBuilder: (context, index) {
                        final gym = gymProvider.userGyms[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GymTile(
                            gym: gym,
                            isSelected:
                                gymProvider.isCheckedIn &&
                                gymProvider.currentGym?.id == gym.id,
                            canCheckIn: !gymProvider.isCheckedIn,
                            onTap: () {
                              // Show gym details or select it
                            },
                            onCheckIn: () async {
                              // Store a reference to ScaffoldMessenger before async operations
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );

                              bool isAtGym = await gymProvider.checkIfAtGym(gym);

                              if (!mounted) return;

                              if (isAtGym) {
                                bool success = await gymProvider.checkInToGym(
                                  userId,
                                  gym,
                                );

                                if (!mounted) return;

                                if (success) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Successfully checked in!'),
                                    ),
                                  );
                                }
                              } else {
                                if (!mounted) return;
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'You need to be at the gym to check in',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            onRemove: () async {
                              if (!mounted) return;

                              bool confirmed = await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Remove Gym'),
                                      content: const Text(
                                        'Are you sure you want to remove this gym? '
                                        'You can add it again later.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('CANCEL'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('REMOVE'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (confirmed) {
                                await gymProvider.removeGym(userId, gym.id);
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFindGymsTab(String userId, GymProvider gymProvider) {
    return Column(
      children: [
        // Debug info row for development
        if (gymProvider.leisureCenters.isEmpty && !_isLoading)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.amber.withAlpha((0.2 * 255).round()),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('No leisure centers found nearby. Try refreshing or expanding search radius.')),
              ],
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              // OpenStreetMap
              _isLoading || _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : OpenStreetMapWidget(
                      initialPosition: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      initialZoom: 14,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _updateMarkers();
                      },
                      onTap: (_) {
                        setState(() {
                          _selectedGym = null;
                          _selectedLeisureCenter = null;
                        });
                      },
                    ),

              // Attribution
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                  child: const Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),

              // Refresh button
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: "refreshButton",
                  onPressed: () {
                    _getCurrentLocation();
                    _refreshGymData();
                  },
                  backgroundColor: Colors.white,
                  mini: true,
                  child: Icon(Icons.refresh, color: kPrimaryColor),
                ),
              ),

              // Legend for gym types
              Positioned(
                top: 16,
                left: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha((0.7 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Your Location',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.purple.withAlpha((0.7 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Your Gyms',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha((0.7 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Other Gyms',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha((0.7 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Leisure Centers',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Selected gym card
              if (_selectedGym != null)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: GymTile(
                      gym: _selectedGym!,
                      isSelected: true,
                      canCheckIn: true,
                      onCheckIn: () async {
                        bool isAtGym = await gymProvider.checkIfAtGym(
                          _selectedGym!,
                        );

                        if (isAtGym) {
                          bool success = await gymProvider.checkInToGym(
                            userId,
                            _selectedGym!,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Successfully checked in!'),
                              ),
                            );

                            // Switch to Your Gyms tab
                            _tabController.animateTo(0);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You need to be at the gym to check in',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),

              // Selected leisure center card
              if (_selectedLeisureCenter != null)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedLeisureCenter!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedLeisureCenter!.address != null &&
                                _selectedLeisureCenter!.address!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(_selectedLeisureCenter!.address!),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedLeisureCenter = null;
                                    });
                                  },
                                  child: const Text('CANCEL'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Convert to Gym and add it
                                    Gym newGym =
                                        _selectedLeisureCenter!.toGym();

                                    bool success = await gymProvider.addNewGym(
                                      newGym,
                                      userId,
                                    );

                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gym added successfully!',
                                          ),
                                        ),
                                      );

                                      setState(() {
                                        _selectedLeisureCenter = null;
                                      });

                                      _tabController.animateTo(0);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            gymProvider.errorMessage ??
                                                'Failed to add gym',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                  ),
                                  child: const Text(
                                    'ADD GYM',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Manual gym button
              Positioned(
                bottom:
                    (_selectedGym != null || _selectedLeisureCenter != null)
                        ? 128
                        : 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _showAddGymDialog,
                  backgroundColor: kPrimaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: kLightTextColor),
          const SizedBox(height: 16),
          Text(
            'No Gyms Registered Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to "Find Gyms" tab to add gyms',
            style: TextStyle(color: kLightTextColor),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Find Gyms',
            onPressed: () {
              _tabController.animateTo(1);
            },
            type: ButtonType.outline,
          ),
        ],
      ),
    );
  }

  void _showAddGymDialog() {
    _nameController.clear();
    _addressController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Gym'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Gym Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isEmpty ||
                  _addressController.text.isEmpty ||
                  _currentPosition == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              Navigator.of(ctx).pop();

              final gymProvider = Provider.of<GymProvider>(
                context,
                listen: false,
              );
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );

              // Create new gym
              Gym newGym = Gym(
                id: DateTime.now().millisecondsSinceEpoch
                    .toString(), // Temporary ID
                name: _nameController.text,
                address: _addressController.text,
                location: GeoPoint(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
              );

              bool success = await gymProvider.addNewGym(
                newGym,
                authProvider.user!.uid,
              );
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gym added successfully!')),
                );

                _tabController.animateTo(0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      gymProvider.errorMessage ?? 'Failed to add gym',
                    ),
                  ),
                );
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}
