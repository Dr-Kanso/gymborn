// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:gymborn_app/services/osm_service.dart';
import 'package:latlong2/latlong.dart';

class OSMMap extends StatefulWidget {
  final LatLng userPosition;

  const OSMMap({super.key, required this.userPosition});

  @override
  State<OSMMap> createState() => OSMMapState();
}

class OSMMapState extends State<OSMMap> {
  final OpenStreetMapService _osmService = OpenStreetMapService();
  List<GeoPoint> gymMarkers = [];

  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController(
      initPosition: GeoPoint(
        latitude: widget.userPosition.latitude,
        longitude: widget.userPosition.longitude,
      ),
    );

    _loadNearbyGyms();
  }

  Future<void> _loadNearbyGyms() async {
    try {
      final gyms = await _osmService.searchNearbyGyms(widget.userPosition);
      if (gyms.isNotEmpty) {
        setState(() {
          gymMarkers = gyms.map((gym) {
            return GeoPoint(
              latitude: double.parse(gym['lat']),
              longitude: double.parse(gym['lon']),
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading gyms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: mapController,
      osmOption: OSMOption(
        zoomOption: ZoomOption(
          initZoom: 14,
          minZoomLevel: 8,
          maxZoomLevel: 18,
          stepZoom: 1.0,
        ),
        userTrackingOption: UserTrackingOption(
          enableTracking: true,
          unFollowUser: false,
        ),
        roadConfiguration: RoadOption(
          roadColor: Colors.blueAccent,
        ),
      ),
      onMapIsReady: (isReady) {
        if (isReady) {
          addGymMarkers();
        }
      },
      onGeoPointClicked: (geoPoint) {
        print('Clicked on: ${geoPoint.toString()}');
      },
      onLocationChanged: (position) {
        print('Location changed: ${position.toString()}');
      },
      mapIsLoading: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Add markers for gym locations
  void addGymMarkers() async {
    if (gymMarkers.isEmpty) return;
    
    // Clear any existing markers
    try {
      await mapController.clearAllRoads();
      final markers = await mapController.geopoints;
      if (markers.isNotEmpty) {
        await mapController.removeMarkers(markers);
      }
    } catch (e) {
      print('Error clearing markers: $e');
    }
    
    // Add gym markers
    for (final gym in gymMarkers) {
      try {
        await mapController.addMarker(
          gym,
          markerIcon: MarkerIcon(
            icon: Icon(Icons.fitness_center, color: Colors.red, size: 48),
          ),
        );
      } catch (e) {
        print('Error adding marker: $e');
      }
    }
    
    // Fit bounds to include all markers
    if (gymMarkers.isNotEmpty) {
      try {
        await mapController.zoomToBoundingBox(
          BoundingBox.fromGeoPoints(gymMarkers),
          paddinInPixel: 50,
        );
      } catch (e) {
        print('Error zooming to bounds: $e');
      }
    }
  }
}
