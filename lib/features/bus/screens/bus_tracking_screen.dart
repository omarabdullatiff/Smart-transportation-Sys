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
  final String? busId;
  
  const BusTrackingScreen({super.key, this.busId});

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

    // Only start bus tracking if busId is provided
    if (widget.busId != null) {
      _startAutomaticTracking();
    }

    // every 10s: update device location, nearby buses, and bus location if tracking
    _locationTimer = Timer.periodic(updateInterval, (_) {
      if (_isTrackingActive && widget.busId != null) {
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
      // Center map on user location if not tracking a specific bus
      if (widget.busId == null || !_isTrackingActive) {
        _mapController.move(_currentDeviceLocation!, 15.0);
      }
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
  Future<void> _startAutomaticTracking() async {
    setState(() {
      _isTrackingActive = true;
      _routePoints.clear();
    });
    _fetchDriverLocation(); // initial
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.busId != null 
          ? 'Started tracking bus ${widget.busId}'
          : 'Started tracking bus'),
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
        content: const Text('Stopped tracking route'),
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
      // Use the provided busId or fall back to hardcoded ID 1
      final trackingId = widget.busId ?? '1';
      final resp = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Tracking/$trackingId/location'),
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
            Text(
              widget.busId != null && _isTrackingActive
                ? 'Tracking Bus ${widget.busId}'
                : 'My Location',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isTrackingActive && widget.busId != null 
                  ? Colors.green 
                  : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isTrackingActive && widget.busId != null 
                      ? Icons.gps_fixed 
                      : Icons.my_location,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isTrackingActive && widget.busId != null 
                      ? 'TRACKING' 
                      : 'GPS',
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
          // status info card
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_isTrackingActive && widget.busId != null 
                      ? Colors.green 
                      : Colors.blue).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isTrackingActive && widget.busId != null 
                      ? Icons.directions_bus 
                      : Icons.my_location,
                    color: _isTrackingActive && widget.busId != null 
                      ? Colors.green 
                      : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTrackingActive && widget.busId != null
                          ? 'Bus ${widget.busId}'
                          : 'Your Location',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _isTrackingActive && widget.busId != null 
                              ? Icons.gps_fixed 
                              : Icons.location_on,
                            size: 16,
                            color: _isTrackingActive && widget.busId != null 
                              ? Colors.green 
                              : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isTrackingActive && widget.busId != null 
                              ? 'Live Tracking' 
                              : 'GPS Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isTrackingActive && widget.busId != null 
                                ? Colors.green 
                                : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isTrackingActive && widget.busId != null 
                      ? Colors.green 
                      : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isTrackingActive && widget.busId != null 
                      ? 'TRACKING' 
                      : 'ACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: (_isTrackingActive && widget.busId != null && _currentDriverLocation != null)
                    ? _currentDriverLocation!
                    : _currentDeviceLocation ?? _defaultCenter,
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

                // Exit tracking button - only show when tracking a specific bus
                if (widget.busId != null && _isTrackingActive) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isTrackingActive = false;
                        _routePoints.clear();
                        _currentDriverLocation = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Switched to GPS location mode'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                      // Focus on user location
                      if (_currentDeviceLocation != null) {
                        _mapController.move(_currentDeviceLocation!, 15.0);
                      }
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Show My Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Center on location button when in GPS mode
                if (widget.busId == null || !_isTrackingActive) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_currentDeviceLocation != null) {
                        _mapController.move(_currentDeviceLocation!, 15.0);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Centered on your location'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      } else {
                        _loadDeviceLocation(); // Try to get location again
                      }
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Center on My Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Show clear button when there are route points
                if (_routePoints.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _routePoints.clear();
                        _currentDriverLocation = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Route'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
              AppColor.primary.withValues(alpha: 0.8),
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
