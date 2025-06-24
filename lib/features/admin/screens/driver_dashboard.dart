import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // Add state variables for location sharing status
  bool _isLocationSharingActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    if (!await _checkLocationPermission()) return;
    
    setState(() {
      _isLocationSharingActive = true;
    });
    
    _updateLocation(); // initial
    _locationTimer = Timer.periodic(updateInterval, (_) => _updateLocation());
  }

  Future<void> _stopLocationTracking() async {
    setState(() {
      _isLoading = true;
    });

    _locationTimer?.cancel();
    _locationTimer = null;
    
    setState(() {
      _isLocationSharingActive = false;
      _isLoading = false;
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location sharing stopped'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Restart',
          textColor: Colors.white,
          onPressed: () => _startLocationTracking(),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await _showLogoutConfirmation();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    // Stop location tracking
    _locationTimer?.cancel();
    _locationTimer = null;

    // Clear stored data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?\n\nThis will stop location sharing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _checkLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint("Location service disabled");
      _showLocationServiceDialog();
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedDialog();
      return false;
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text('Please enable location services to share your location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('Location permission is required to share your location. Please enable it in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Location sharing status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isLocationSharingActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLocationSharingActive ? Icons.gps_fixed : Icons.gps_off,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _isLocationSharingActive ? 'LIVE' : 'OFF',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColor.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Location Sharing Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusInfo(
                        'Status',
                        _isLocationSharingActive ? 'Active' : 'Stopped',
                        _isLocationSharingActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusInfo(
                        'Update Interval',
                        '${updateInterval.inSeconds}s',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                if (_currentLocation != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusInfo(
                          'Latitude',
                          _currentLocation!.latitude.toStringAsFixed(6),
                          Colors.grey[700]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusInfo(
                          'Longitude',
                          _currentLocation!.longitude.toStringAsFixed(6),
                          Colors.grey[700]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
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
              ),
            ),
          ),
          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading 
                        ? null 
                        : _isLocationSharingActive 
                            ? _stopLocationTracking 
                            : _startLocationTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLocationSharingActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(_isLocationSharingActive ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      _isLoading
                          ? 'Processing...'
                          : _isLocationSharingActive
                              ? 'Stop Sharing Location'
                              : 'Start Sharing Location',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
