import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class RouteService {
  static const String _openRouteServiceKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjQ1NTI3ZmFjYjRlNTRmYTRhYjI5N2MxODRkNjkxNmRhIiwiaCI6Im11cm11cjY0In0=';

  /// Fetches origin and destination coordinates for a specific bus
  static Future<RouteCoordinates?> fetchBusRouteCoordinates(int busId) async {
    try {
      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Stops/bus/$busId/route-coordinates'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RouteCoordinates.fromJson(data);
      } else {
        debugPrint('Failed to fetch route coordinates: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching route coordinates: $e');
      return null;
    }
  }

  /// Fetches driving directions between two points using OpenRouteService
  static Future<List<LatLng>?> fetchDrivingDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car/geojson'),
        headers: {
          'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
          'Authorization': _openRouteServiceKey,
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode({
          'coordinates': [
            [origin.longitude, origin.latitude],
            [destination.longitude, destination.latitude],
          ],
          'format': 'geojson',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['features'][0]['geometry']['coordinates'] as List;
        
        return coordinates.map<LatLng>((coord) {
          return LatLng(coord[1].toDouble(), coord[0].toDouble());
        }).toList();
      } else {
        debugPrint('Failed to fetch directions: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
      return null;
    }
  }

  /// Fetches complete route information including coordinates and directions
  static Future<BusRouteInfo?> fetchCompleteRouteInfo(int busId) async {
    try {
      final coordinates = await fetchBusRouteCoordinates(busId);
      if (coordinates == null) return null;

      final origin = LatLng(coordinates.originLatitude, coordinates.originLongitude);
      final destination = LatLng(coordinates.destinationLatitude, coordinates.destinationLongitude);
      
      final directions = await fetchDrivingDirections(origin, destination);
      if (directions == null) return null;

      return BusRouteInfo(
        coordinates: coordinates,
        routePoints: directions,
      );
    } catch (e) {
      debugPrint('Error fetching complete route info: $e');
      return null;
    }
  }
}

/// Model class for route coordinates from the API
class RouteCoordinates {
  final String originName;
  final double originLatitude;
  final double originLongitude;
  final String destinationName;
  final double destinationLatitude;
  final double destinationLongitude;

  RouteCoordinates({
    required this.originName,
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationName,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  factory RouteCoordinates.fromJson(Map<String, dynamic> json) {
    return RouteCoordinates(
      originName: json['originName'] ?? 'Unknown Origin',
      originLatitude: (json['originLatitude'] ?? 0.0).toDouble(),
      originLongitude: (json['originLongitude'] ?? 0.0).toDouble(),
      destinationName: json['destinationName'] ?? 'Unknown Destination',
      destinationLatitude: (json['destinationLatitude'] ?? 0.0).toDouble(),
      destinationLongitude: (json['destinationLongitude'] ?? 0.0).toDouble(),
    );
  }

  LatLng get originLatLng => LatLng(originLatitude, originLongitude);
  LatLng get destinationLatLng => LatLng(destinationLatitude, destinationLongitude);
}

/// Combined model for complete route information
class BusRouteInfo {
  final RouteCoordinates coordinates;
  final List<LatLng> routePoints;

  BusRouteInfo({
    required this.coordinates,
    required this.routePoints,
  });
} 