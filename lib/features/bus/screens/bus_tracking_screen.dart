import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
  
  // New variables for route tracking
  List<LatLng> _routePoints = [];
  LatLng? _currentDriverLocation;
  bool _isTrackingActive = false;
  DateTime? _lastLocationUpdate;
  static const Duration updateInterval = Duration(seconds: 10);
  final LatLng _defaultCenter = const LatLng(30.033333, 31.233334); // Cairo default

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRouteTracking() async {
    setState(() {
      _isTrackingActive = true;
      _routePoints.clear(); // Clear previous route
    });
    
    _fetchDriverLocation(); // Initial fetch
    _locationTimer = Timer.periodic(updateInterval, (_) => _fetchDriverLocation());
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started tracking driver route'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _stopRouteTracking() async {
    _locationTimer?.cancel();
    _locationTimer = null;
    
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
  }

  Future<void> _fetchDriverLocation() async {
    try {
      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/AdminDriver/36/location'),
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newLocation = LatLng(
          data['latitude'].toDouble(),
          data['longitude'].toDouble(),
        );

        // Check if location actually changed to avoid duplicate points
        bool locationChanged = _currentDriverLocation == null ||
            _currentDriverLocation!.latitude != newLocation.latitude ||
            _currentDriverLocation!.longitude != newLocation.longitude;

        if (locationChanged) {
          setState(() {
            _currentDriverLocation = newLocation;
            _routePoints.add(newLocation);
            _lastLocationUpdate = DateTime.now();
          });

          // Center map on new location
          _mapController.move(newLocation, _mapController.camera.zoom);
        }
      } else {
        debugPrint("Failed to fetch driver location: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching driver location: $e");
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Account/getCurrentUser'),
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            userData = responseData;
            isLoading = false;
          });
        }
      } else {
        await prefs.clear();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load user data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Bus Tracking',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Tracking status indicator
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

      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.primary,
                AppColor.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: Column(
                  children: [
                    if (isLoading)
                      const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    else
                      Column(
                        children: [
                          Text(
                            userData?['displayName'] ?? 'omar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            userData?['email'] ?? 'email@example.com',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
                        onTap: () {
                          Navigator.pushNamed(context, '/booking');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.search_off,
                        title: 'Lost Items',
                        onTap: () {
                          Navigator.pushNamed(context, '/loses');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.find_in_page,
                        title: 'Found Items',
                        onTap: () {
                          Navigator.pushNamed(context, '/founditem');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () {
                          Navigator.pushNamed(context, '/setting');
                        },
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
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // Route info card
          if (_currentDriverLocation != null)
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
                        Icons.route,
                        color: AppColor.primary,
                        size: 24,
                      ),
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
                            _currentDriverLocation!.latitude.toStringAsFixed(6),
                            Colors.grey[700]!,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRouteInfo(
                            'Longitude',
                            _currentDriverLocation!.longitude.toStringAsFixed(6),
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
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentDriverLocation ?? _defaultCenter,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // Route polyline
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
                    // Driver location marker only
                    if (_currentDriverLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: _currentDriverLocation!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
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
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route tracking controls
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTrackingActive ? _stopRouteTracking : _startRouteTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTrackingActive ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(_isTrackingActive ? Icons.stop : Icons.play_arrow),
                        label: Text(
                          _isTrackingActive ? 'Stop Tracking' : 'Start Tracking',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Original navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/buslist');
                        },
                        child: const Text(
                          'All Buses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/booking');
                        },
                        child: const Text(
                          "Search",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildRouteInfo(String label, String value, Color color) {
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColor.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
