import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationTracker extends StatefulWidget {
  const LocationTracker({super.key});

  @override
  State<LocationTracker> createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  final MapController _mapController = MapController();
  final ValueNotifier<List<Marker>> _markersNotifier = ValueNotifier([]);
  Timer? _locationTimer;

  LatLng? _currentLocation;
  LatLng? _serverLocation;
  final LatLng _defaultCenter = const LatLng(30.033333, 31.233334); // Cairo fallback

  static const Duration updateInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    if (!await _checkLocationPermission()) return;
    _updateLocation(); // initial
    _locationTimer = Timer.periodic(updateInterval, (_) => _updateLocation());
  }

  Future<bool> _checkLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint("Location service disabled");
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final newLocation = LatLng(position.latitude, position.longitude);

      final locationChanged = _currentLocation == null ||
          _currentLocation!.latitude != newLocation.latitude ||
          _currentLocation!.longitude != newLocation.longitude;

      if (locationChanged) {
        _currentLocation = newLocation;
        _mapController.move(_currentLocation!, _mapController.camera.zoom);
        _refreshMarkers();
      }

      // Run these in parallel
      unawaited(_sendLocationToServer(newLocation));
      unawaited(_fetchLastServerLocation());
    } catch (e) {
      debugPrint("Location update error: $e");
    }
  }

  void _refreshMarkers() {
    final markers = <Marker>[
      if (_currentLocation != null)
        Marker(
          point: _currentLocation!,
          width: 50,
          height: 50,
          child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
        ),
      if (_serverLocation != null)
        Marker(
          point: _serverLocation!,
          width: 50,
          height: 50,
          child: const Icon(Icons.location_on, size: 40, color: Colors.green),
        ),
    ];

    _markersNotifier.value = markers;
  }

  Future<void> _sendLocationToServer(LatLng location) async {
    try {
      final response = await http.post(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Tracking'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "busId": 0,
          "latitude": location.latitude,
          "longitude": location.longitude,
        }),
      );
      debugPrint("Location sent. Status: ${response.statusCode}");
    } catch (e) {
      debugPrint("POST error: $e");
    }
  }

  Future<void> _fetchLastServerLocation() async {
    try {
      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/AdminDriver/1/location'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverLoc = LatLng(data['latitude'], data['longitude']);

        if (_serverLocation == null ||
            _serverLocation!.latitude != serverLoc.latitude ||
            _serverLocation!.longitude != serverLoc.longitude) {
          _serverLocation = serverLoc;
          _refreshMarkers();
        }
      } else {
        debugPrint("GET failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("GET error: $e");
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _markersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live & Server Location')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation ?? _defaultCenter,
          initialZoom: 15.5,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          ValueListenableBuilder<List<Marker>>(
            valueListenable: _markersNotifier,
            builder: (context, markers, _) => MarkerLayer(markers: markers),
          ),
        ],
      ),
    );
  }
}
