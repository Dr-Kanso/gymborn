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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
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
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true would be handled).
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, please enable from settings',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.move(LatLng(position.latitude, position.longitude), 14);
        _updateMarkers();
      }
    } catch (e) {
      print('Error getting position: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  Future<void> _loadNearbyGyms() async {
    final gymProvider = Provider.of<GymProvider>(context, listen: false);
    await gymProvider.loadNearbyGyms(5000); // 5km radius

    // Load leisure centers if position is available
    if (_currentPosition != null) {
      await gymProvider.loadLeisureCenters(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        5000, // 5km radius
      );
    }

    _updateMarkers();
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
        child: const Icon(
          Icons.location_history,
          color: Colors.blue,
          size: 40.0,
        ),
      ),
    );

    // User's registered gyms
    for (var gym in gymProvider.userGyms) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: gym.latLng,
          child: const Icon(
            Icons.fitness_center,
            color: Colors.purple,
            size: 40.0,
          ),
        ),
      );
    }

    // Nearby gyms
    for (var gym in gymProvider.nearbyGyms) {
      // Skip if already in user gyms
      if (gymProvider.userGyms.any((userGym) => userGym.id == gym.id)) continue;

      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: gym.latLng,
          child: const Icon(
            Icons.fitness_center,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    }

    // Leisure centers
    for (var center in gymProvider.leisureCenters) {
      // Skip if this center is already a registered gym
      if (gymProvider.userGyms.any((gym) => gym.id == center.id)) continue;

      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(center.latitude, center.longitude),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedLeisureCenter = center;
                _selectedGym = null; // Clear any selected gym
              });
            },
            child: const Icon(
              Icons.fitness_center,
              color: Colors.green,
              size: 40.0,
            ),
          ),
        ),
      );
    }

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
          color: kPrimaryColor.withAlpha(
            (0.1 * 255).round(),
          ), // Changed from withOpacity
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
          child:
              gymProvider.isLoading
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

                            bool confirmed =
                                await showDialog(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text('Remove Gym'),
                                        content: const Text(
                                          'Are you sure you want to remove this gym? '
                                          'You can add it again later.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                            child: const Text('CANCEL'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () =>
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
                      });
                    },
                  ),

              // Attribution
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.white.withAlpha(
                    (0.7 * 255).round(),
                  ), // Changed from withOpacity
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
                  onPressed: () {
                    _getCurrentLocation();
                    _loadNearbyGyms();
                  },
                  backgroundColor: Colors.white,
                  mini: true,
                  child: Icon(Icons.refresh, color: kPrimaryColor),
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
      builder:
          (ctx) => AlertDialog(
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
                    id:
                        DateTime.now().millisecondsSinceEpoch
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
