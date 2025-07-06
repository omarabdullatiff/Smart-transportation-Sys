import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/features/bus/screens/location_service.dart';
import 'package:flutter_application_1/features/bus/services/route_service.dart';
import 'dart:convert';
import 'dart:async';

class BusTrackingScreen extends StatefulWidget {
  final String? busId;
  final bool showRouteOnStart;
  
  const BusTrackingScreen({super.key, this.busId, this.showRouteOnStart = false});

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
  String? _selectedBusId; // For tracking selected nearby buses

  // for device location & nearby buses
  LatLng? _currentDeviceLocation;
  List<Marker> _nearbyBusMarkers = [];
  List<Map<String, dynamic>> _nearbyBusesData = [];

  // for route visualization
  List<LatLng> _busRoutePoints = [];
  Marker? _originMarker;
  Marker? _destinationMarker;
  bool _isLoadingRoute = false;
  bool _showRouteMode = false;

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

    // Show route on start if requested
    if (widget.showRouteOnStart && widget.busId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBusRoute(int.tryParse(widget.busId!) ?? 1);
      });
    }

    // every 10s: update device location, nearby buses, and bus location if tracking
    _locationTimer = Timer.periodic(updateInterval, (_) {
      if (_isTrackingActive) {
        if (_selectedBusId != null) {
          // Prioritize manually selected bus from nearby buses
          _fetchSelectedBusLocation(_selectedBusId!);
        } else if (widget.busId != null) {
          // Use bus ID from navigation (from bus details page)
          _fetchDriverLocation();
        }
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
        
        // Store bus data for popup usage - using actual API structure
        final busesData = buses.map((bus) => {
          'busId': bus['busId'] ?? 0,
          'latitude': (bus['latitude'] ?? 0.0).toDouble(),
          'longitude': (bus['longitude'] ?? 0.0).toDouble(),
          'origin': bus['origin']?.toString() ?? 'Unknown Origin',
          'destination': bus['destination']?.toString() ?? 'Unknown Destination',
          'capacity': 40, // Static capacity as not provided in API
          'driverId': bus['driverId'],
        }).where((bus) => 
          // Filter out buses with invalid coordinates (0,0)
          bus['latitude'] != 0.0 || bus['longitude'] != 0.0
        ).toList();
        
        final markers = busesData.map((bus) {
          return Marker(
            point: LatLng(bus['latitude'], bus['longitude']),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showBusInfoPopup(bus),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList();

        setState(() {
          _nearbyBusesData = busesData;
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
      // Only proceed if we have a valid busId
      final trackingId = widget.busId;
      if (trackingId == null) {
        debugPrint('No busId provided for tracking');
        return;
      }
      
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

  // —— ROUTE VISUALIZATION ——
  Future<void> _showAllBusRoutes() async {
    final busId = widget.busId != null ? int.tryParse(widget.busId!) ?? 1 : 1;
    await _showBusRoute(busId);
  }

  Future<void> _showBusRoute(int busId) async {
    setState(() {
      _isLoadingRoute = true;
      _showRouteMode = true;
    });

    try {
      final routeInfo = await RouteService.fetchCompleteRouteInfo(busId);
      
      if (routeInfo != null) {
        _displayRoute(routeInfo);
        
        // Center map to show the entire route
        _centerMapOnRoute(routeInfo.routePoints);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Route loaded: ${routeInfo.coordinates.originName} → ${routeInfo.coordinates.destinationName}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Clear',
              textColor: Colors.white,
              onPressed: _clearRoute,
            ),
          ),
        );
      } else {
        throw Exception('Failed to load route information');
      }
    } catch (e) {
      debugPrint('Error loading route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load route: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  void _displayRoute(BusRouteInfo routeInfo) {
    setState(() {
      _busRoutePoints = routeInfo.routePoints;
      
      // Create origin marker
      _originMarker = Marker(
        point: routeInfo.coordinates.originLatLng,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                routeInfo.coordinates.originName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      );

      // Create destination marker
      _destinationMarker = Marker(
        point: routeInfo.coordinates.destinationLatLng,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                routeInfo.coordinates.destinationName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      );
    });
  }

  void _centerMapOnRoute(List<LatLng> routePoints) {
    if (routePoints.isEmpty) return;

    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;

    for (final point in routePoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
    
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  void _clearRoute() {
    setState(() {
      _busRoutePoints.clear();
      _originMarker = null;
      _destinationMarker = null;
      _showRouteMode = false;
    });
    
    // Return to user location
    if (_currentDeviceLocation != null) {
      _mapController.move(_currentDeviceLocation!, 15.0);
    }
  }

  // —— NEARBY BUS POPUP ——
  void _showBusInfoPopup(Map<String, dynamic> busData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bus ${busData['busId']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'From',
                value: busData['origin'],
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.flag,
                label: 'To',
                value: busData['destination'],
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.people,
                label: 'Capacity',
                value: '${busData['capacity']} passengers',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.person,
                label: 'Driver',
                value: busData['driverId'] != null 
                  ? 'Driver ID: ${busData['driverId']}'
                  : 'Not assigned',
                color: busData['driverId'] != null ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        busData['driverId'] != null 
                          ? 'This bus is active and nearby your location'
                          : 'This bus is nearby but no driver assigned',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _startTrackingSelectedBus(busData);
              },
              icon: const Icon(Icons.gps_fixed, size: 18),
              label: const Text('Track This Bus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _startTrackingSelectedBus(Map<String, dynamic> busData) {
    setState(() {
      _isTrackingActive = true;
      _routePoints.clear();
      _currentDriverLocation = null;
      _selectedBusId = busData['busId'].toString(); // Store selected bus ID
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started tracking Bus ${_selectedBusId}'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Stop',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isTrackingActive = false;
              _routePoints.clear();
              _currentDriverLocation = null;
              _selectedBusId = null;
            });
          },
        ),
      ),
    );

    // Start fetching location for the selected bus
    _fetchSelectedBusLocation(_selectedBusId!);
  }

  Future<void> _fetchSelectedBusLocation(String busId) async {
    try {
      final resp = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Tracking/$busId/location'),
        headers: {'accept': '*/*'},
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final newLoc = LatLng(
          (data['latitude'] as num).toDouble(),
          (data['longitude'] as num).toDouble(),
        );
        
        setState(() {
          _currentDriverLocation = newLoc;
          _routePoints.add(newLoc);
          _lastLocationUpdate = DateTime.now();
        });
        _mapController.move(newLoc, 16.0);
      } else {
        debugPrint('Fetch selected bus failed: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching selected bus: $e');
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
              _showRouteMode
                ? 'Bus Route View'
                : _isTrackingActive
                  ? (widget.busId != null 
                      ? 'Tracking Bus ${widget.busId}'
                      : _selectedBusId != null
                        ? 'Tracking Bus $_selectedBusId'
                        : 'My Location')
                  : 'My Location',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _showRouteMode
                  ? Colors.blue
                  : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                    ? Colors.green 
                    : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showRouteMode
                      ? Icons.route
                      : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                        ? Icons.gps_fixed 
                        : Icons.my_location,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showRouteMode
                      ? 'ROUTE'
                      : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
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
                    color: (_showRouteMode
                      ? Colors.blue
                      : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                        ? Colors.green 
                        : Colors.blue).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _showRouteMode
                      ? Icons.route
                      : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                        ? Icons.directions_bus 
                        : Icons.my_location,
                    color: _showRouteMode
                      ? Colors.blue
                      : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
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
                        _showRouteMode
                          ? 'Bus Route View'
                          : _isTrackingActive
                            ? (widget.busId != null 
                                ? 'Bus ${widget.busId}'
                                : _selectedBusId != null
                                  ? 'Bus $_selectedBusId'
                                  : 'Your Location')
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
                            _showRouteMode
                              ? Icons.route
                              : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                                ? Icons.gps_fixed 
                                : Icons.location_on,
                            size: 16,
                            color: _showRouteMode
                              ? Colors.blue
                              : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                                ? Colors.green 
                                : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showRouteMode
                              ? 'Showing Route'
                              : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                                ? 'Live Tracking' 
                                : 'GPS Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: _showRouteMode
                                ? Colors.blue
                                : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
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
                    color: _showRouteMode
                      ? Colors.blue
                      : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
                        ? Colors.green 
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _showRouteMode
                      ? 'ROUTE'
                      : _isTrackingActive && (widget.busId != null || _selectedBusId != null)
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
                initialCenter: (_isTrackingActive && (widget.busId != null || _selectedBusId != null) && _currentDriverLocation != null)
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
                // Bus route polyline (if in route mode)
                if (_busRoutePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _busRoutePoints,
                        strokeWidth: 5.0,
                        color: Colors.blue,
                        borderStrokeWidth: 2.0,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),
                // Live tracking polyline (if tracking)
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
                    // Origin marker (route mode)
                    if (_originMarker != null) _originMarker!,
                    // Destination marker (route mode)
                    if (_destinationMarker != null) _destinationMarker!,
                    // Live tracking bus marker
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
                    // User location marker
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
                    // Nearby bus markers (only show if not in route mode)
                    if (!_showRouteMode) ..._nearbyBusMarkers,
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
                if ((widget.busId != null || _selectedBusId != null) && _isTrackingActive) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isTrackingActive = false;
                        _routePoints.clear();
                        _currentDriverLocation = null;
                        _selectedBusId = null; // Clear selected bus ID
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
                if ((widget.busId == null && _selectedBusId == null) || !_isTrackingActive) ...[
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
                
                // Unified clear button for both route types
                if (_routePoints.isNotEmpty || _showRouteMode) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_showRouteMode) {
                        _clearRoute(); // Clear route visualization
                      } else {
                        // Clear live tracking route
                        setState(() {
                          _routePoints.clear();
                          _currentDriverLocation = null;
                        });
                      }
                    },
                    icon: Icon(_showRouteMode ? Icons.clear_all : Icons.clear),
                    label: Text(_showRouteMode ? 'Clear Route View' : 'Clear Tracking'),
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
