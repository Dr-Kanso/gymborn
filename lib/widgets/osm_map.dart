import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final List<Marker> markers;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final Function(MapController)? onMapCreated;
  final Function(LatLng)? onTap;

  const OpenStreetMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14.0,
    this.markers = const [],
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.zoomControlsEnabled = false,
    this.onMapCreated,
    this.onTap,
  });

  @override
  State<OpenStreetMapWidget> createState() => _OpenStreetMapWidgetState();
}

class _OpenStreetMapWidgetState extends State<OpenStreetMapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.onMapCreated != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMapCreated!(_mapController);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialPosition,
            initialZoom: widget.initialZoom,
            onTap:
                widget.onTap != null
                    ? (tapPosition, point) => widget.onTap!(point)
                    : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.gymborn',
              additionalOptions: const {
                'attribution': '© OpenStreetMap contributors',
              },
            ),
            MarkerLayer(markers: widget.markers),
          ],
        ),

        // Show location button if enabled
        if (widget.myLocationButtonEnabled)
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {},
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
      ],
    );
  }
}

// Helper class to convert between Google Maps camera positions and OSM
class CameraUpdate {
  static MapPosition newCameraPosition(CameraPosition position) {
    return MapPosition(center: position.target, zoom: position.zoom);
  }
}

class CameraPosition {
  final LatLng target;
  final double zoom;

  const CameraPosition({required this.target, this.zoom = 14.0});
}
