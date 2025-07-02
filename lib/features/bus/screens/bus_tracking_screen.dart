import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_1/features/bus/screens/location_service.dart';
import 'dart:convert';
import 'dart:async';

class BusTrackingScreen extends StatefulWidget {
  const BusTrackingScreen({super.key});

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _locationTimer;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  // for driver‐route tracking
  List<LatLng> _routePoints = [];
  LatLng? _currentDriverLocation;
  bool _isTrackingActive = false;
  DateTime? _lastLocationUpdate;

  // for device location & nearby buses
  LatLng? _currentDeviceLocation;
  List<Marker> _nearbyBusMarkers = [];

  static const Duration updateInterval = Duration(seconds: 10);
  final LatLng _defaultCenter = const LatLng(30.033333, 31.233334); // Cairo

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadDeviceLocation();

    // every 10s: update driver (if tracking), device location & nearby buses
    _locationTimer = Timer.periodic(updateInterval, (_) {
      if (_isTrackingActive) {
        _fetchDriverLocation();
      }
      _refreshDeviceAndNearby();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  // —— DEVICE LOCATION & NEARBY BUSES ——
  Future<void> _loadDeviceLocation() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _currentDeviceLocation = LatLng(pos.latitude, pos.longitude);
      });
      _mapController.move(_currentDeviceLocation!, _mapController.camera.zoom);
    }
  }

  Future<void> _refreshDeviceAndNearby() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos == null) return;
      final devLoc = LatLng(pos.latitude, pos.longitude);

      // update device marker
      setState(() {
        _currentDeviceLocation = devLoc;
      });

      // fetch nearby buses
      final resp = await http.get(
        Uri.parse(
          'http://smarttrackingapp.runasp.net/api/Tracking/nearby'
              '?radiusMeters=1000&latitude=${pos.latitude}&longitude=${pos.longitude}',
        ),
        headers: {'accept': '*/*'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> buses = json.decode(resp.body);
        final markers = buses.map((bus) {
          return Marker(
            point: LatLng(bus['latitude'], bus['longitude']),
            width: 40,
            height: 40,
            child: const Icon(
              Icons.directions_bus,
              size: 28,
              color: Colors.blue,
            ),
          );
        }).toList();

        setState(() {
          _nearbyBusMarkers = markers;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing device/nearby: $e');
    }
  }

  // —— DRIVER ROUTE TRACKING ——
  Future<void> _startRouteTracking() async {
    setState(() {
      _isTrackingActive = true;
      _routePoints.clear();
    });
    _fetchDriverLocation(); // initial
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started tracking driver route'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _stopRouteTracking() async {
    _locationTimer?.cancel(); // stops all timers
    setState(() {
      _isTrackingActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Stopped tracking driver route'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Clear Route',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _routePoints.clear();
              _currentDriverLocation = null;
            });
          },
        ),
      ),
    );
    // restart timer to keep nearby updates running
    _locationTimer = Timer.periodic(updateInterval, (_) {
      _refreshDeviceAndNearby();
    });
  }

  Future<void> _fetchDriverLocation() async {
    try {
      final resp = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Tracking/1/location'),
        headers: {'accept': '*/*'},
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final newLoc = LatLng(
          (data['latitude'] as num).toDouble(),
          (data['longitude'] as num).toDouble(),
        );
        final changed = _currentDriverLocation == null ||
            _currentDriverLocation!.latitude != newLoc.latitude ||
            _currentDriverLocation!.longitude != newLoc.longitude;

        if (changed) {
          setState(() {
            _currentDriverLocation = newLoc;
            _routePoints.add(newLoc);
            _lastLocationUpdate = DateTime.now();
          });
          _mapController.move(newLoc, _mapController.camera.zoom);
        }
      } else {
        debugPrint('Fetch driver failed: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching driver: $e');
    }
  }

  // —— USER DATA ——
  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final resp = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Account/getCurrentUser'),
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);
        if (mounted) {
          setState(() {
            userData = responseData;
            isLoading = false;
          });
        }
      } else {
        await prefs.clear();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load user data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // —— BUILD ——
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (c) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(c).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Bus Tracking',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Tracking status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isTrackingActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isTrackingActive ? Icons.gps_fixed : Icons.gps_off,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isTrackingActive ? 'LIVE' : 'OFF',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      drawer: _buildDrawer(),

      body: Column(
        children: [
          // route info card
          if (_currentDriverLocation != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.route, color: AppColor.primary, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Driver Route Information',
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
                        child: _buildRouteInfo(
                          'Route Points',
                          '${_routePoints.length}',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRouteInfo(
                          'Status',
                          _isTrackingActive ? 'Tracking' : 'Stopped',
                          _isTrackingActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (_lastLocationUpdate != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRouteInfo(
                            'Latitude',
                            _currentDriverLocation!.latitude.toString(),
                            Colors.grey[700]!,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRouteInfo(
                            'Longitude',
                            _currentDriverLocation!.longitude.toString(),
                            Colors.grey[700]!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

          // map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentDriverLocation ??
                    _currentDeviceLocation ??
                    _defaultCenter,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_routePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: AppColor.primary,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_currentDriverLocation != null)
                      Marker(
                        width: 50,
                        height: 50,
                        point: _currentDriverLocation!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    if (_currentDeviceLocation != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: _currentDeviceLocation!,
                        child: const Icon(
                          Icons.location_on,
                          size: 28,
                          color: Colors.green,
                        ),
                      ),
                    ..._nearbyBusMarkers,
                  ],
                ),
              ],
            ),
          ),

          // controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // route tracking
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTrackingActive
                            ? _stopRouteTracking
                            : _startRouteTracking,
                        icon: Icon(
                            _isTrackingActive ? Icons.stop : Icons.play_arrow),
                        label: Text(
                          _isTrackingActive ? 'Stop Tracking' : 'Start Tracking',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _isTrackingActive ? Colors.red : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_routePoints.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _routePoints.clear();
                            _currentDriverLocation = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // navigation
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/buslist'),
                        child: const Text('All Buses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/booking'),
                        child: const Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // drawer builder
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary,
              AppColor.primary.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(
                children: [
                  Text(
                    userData?['displayName'] ?? 'User',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userData?['email'] ?? '',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: 20),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.search,
                      title: 'Search Bus',
                      onTap: () => Navigator.pushNamed(context, '/booking'),
                    ),
                    _buildDrawerItem(
                      icon: Icons.search_off,
                      title: 'Lost Items',
                      onTap: () => Navigator.pushNamed(context, '/loses'),
                    ),
                    _buildDrawerItem(
                      icon: Icons.find_in_page,
                      title: 'Found Items',
                      onTap: () => Navigator.pushNamed(context, '/founditem'),
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => Navigator.pushNamed(context, '/setting'),
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      title: 'About Us',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (r) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text("Logout", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // small helpers
  Widget _buildRouteInfo(String label, String value, Color color) => Column(
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icon, color: AppColor.primary, size: 22),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      );
}
