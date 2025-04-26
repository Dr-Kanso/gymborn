import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OpenStreetMapService {
  // Base URL for Nominatim API (OpenStreetMap's search API)
  final String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Remember to include a proper User-Agent as per OSM policy
  final Map<String, String> _headers = {'User-Agent': 'GymBornApp/1.0.0'};

  // Search for a location by name
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final url = Uri.parse('$_baseUrl/search?q=$query&format=json&limit=10');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to search location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching location: $e');
    }
  }

  // Reverse geocoding - get address from coordinates
  Future<Map<String, dynamic>> reverseGeocode(LatLng position) async {
    final url = Uri.parse(
      '$_baseUrl/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json',
    );

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to reverse geocode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error reverse geocoding: $e');
    }
  }

  // Search for leisure centers (gyms) near the user's location
  Future<List<Map<String, dynamic>>> searchNearbyGyms(LatLng position) async {
    String query = 'leisure center near ${position.latitude},${position.longitude}';
    return await searchLocation(query);
  }
}
