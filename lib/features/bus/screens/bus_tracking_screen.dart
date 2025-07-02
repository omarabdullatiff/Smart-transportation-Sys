import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/bus/screens/location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
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

  List<LatLng> _routePoints = [];
  LatLng? _currentDriverLocation;
  List<Marker> _nearbyBusMarkers = [];

  final LatLng _defaultCenter = const LatLng(30.033333, 31.233334); // Cairo

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadDeviceLocation();

    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _refreshDriverLocation();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeviceLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentDriverLocation = newLocation;
        _routePoints = [newLocation];
      });
      _mapController.move(newLocation, 16.0);
    }
  }

  Future<void> _refreshDriverLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position == null) return;

    final newLocation = LatLng(position.latitude, position.longitude);

    // Only update UI if position changed significantly ( > 5 meters)
    if (_currentDriverLocation != null) {
      final distance = Geolocator.distanceBetween(
        _currentDriverLocation!.latitude,
        _currentDriverLocation!.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      if (distance < 5) return;
    }

    setState(() {
      _currentDriverLocation = newLocation;
      _routePoints.add(newLocation);
    });

    _mapController.move(newLocation, _mapController.camera.zoom);

    try {
      final response = await http.get(
        Uri.parse(
          'http://smarttrackingapp.runasp.net/api/Tracking/nearby?radiusMeters=1000'
              '&latitude=${position.latitude}&longitude=${position.longitude}',
        ),
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> buses = json.decode(response.body);

        List<Marker> newBusMarkers = buses.map((bus) {
          final lat = bus['latitude'];
          final lng = bus['longitude'];

          return Marker(
            point: LatLng(lat, lng),
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
          _nearbyBusMarkers = newBusMarkers;
        });
      }
    } catch (e) {
      debugPrint('Error fetching nearby buses: $e');
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
                AppColor.primary.withOpacity(0.8),
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
                      const CircularProgressIndicator(color: Colors.white)
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
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
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
                  label: const Text("Logout", style: TextStyle(fontSize: 16)),
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
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          ..._nearbyBusMarkers,
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                    onPressed: () => Navigator.pushNamed(context, '/buslist'),
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
                    onPressed: () => Navigator.pushNamed(context, '/booking'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColor.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
