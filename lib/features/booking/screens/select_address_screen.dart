import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/features/bus/screens/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class Bus {
  final int id;
  final String name;
  final String origin;
  final String destination;

  Bus({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
  });

  factory Bus.fromJson(Map<String, dynamic> json) => Bus(
    id: json['id'] ?? 0,
    name: json['name'] ?? 'Bus',
    origin: json['origin'] ?? 'Unknown Origin',
    destination: json['destination'] ?? 'Unknown Destination',
  );
}

class NearbyBus {
  final int busId;
  final double latitude;
  final double longitude;
  final int? driverId;
  final String? origin;
  final String? destination;

  NearbyBus({
    required this.busId,
    required this.latitude,
    required this.longitude,
    this.driverId,
    this.origin,
    this.destination,
  });

  factory NearbyBus.fromJson(Map<String, dynamic> json) => NearbyBus(
    busId: json['busId'] ?? 0,
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    driverId: json['driverId'],
    origin: json['origin'],
    destination: json['destination'],
  );
}

class LocationSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;
  final String placeId;
  final String type;

  LocationSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.type,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      latitude: double.tryParse(json['lat'] ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon'] ?? '0') ?? 0.0,
      placeId: json['place_id']?.toString() ?? '',
      type: json['type'] ?? 'place',
    );
  }
}

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final FocusNode originFocusNode = FocusNode();
  final FocusNode destinationFocusNode = FocusNode();

  List<Bus> buses = [];
  List<NearbyBus> nearbyBuses = [];
  List<LocationSuggestion> originSuggestions = [];
  List<LocationSuggestion> destinationSuggestions = [];

  bool isLoading = false;
  bool isLoadingNearby = false;
  bool isDetectingLocation = false;
  bool isLoadingOriginSuggestions = false;
  bool isLoadingDestinationSuggestions = false;
  bool showOriginSuggestions = false;
  bool showDestinationSuggestions = false;

  String errorMsg = '';
  String nearbyErrorMsg = '';
  String locationErrorMsg = '';

  Timer? _originDebounceTimer;
  Timer? _destinationDebounceTimer;

  double? originLat, originLng;
  double? destinationLat, destinationLng;

  @override
  void initState() {
    super.initState();
    _autoDetectLocation();
    originController.addListener(_onOriginTextChanged);
    destinationController.addListener(_onDestinationTextChanged);

    originFocusNode.addListener(() {
      if (!originFocusNode.hasFocus) setState(() => showOriginSuggestions = false);
    });
    destinationFocusNode.addListener(() {
      if (!destinationFocusNode.hasFocus) setState(() => showDestinationSuggestions = false);
    });
  }

  @override
  void dispose() {
    _originDebounceTimer?.cancel();
    _destinationDebounceTimer?.cancel();
    originController.dispose();
    destinationController.dispose();
    originFocusNode.dispose();
    destinationFocusNode.dispose();
    super.dispose();
  }

  void _onOriginTextChanged() {
    final q = originController.text.trim();
    if (q.length >= 2) {
      _originDebounceTimer?.cancel();
      _originDebounceTimer = Timer(
          const Duration(milliseconds: 500), () => _searchLocationSuggestions(q, isOrigin: true));
    } else {
      setState(() {
        originSuggestions.clear();
        showOriginSuggestions = false;
      });
    }
  }

  void _onDestinationTextChanged() {
    final q = destinationController.text.trim();
    if (q.length >= 2) {
      _destinationDebounceTimer?.cancel();
      _destinationDebounceTimer = Timer(
          const Duration(milliseconds: 500), () => _searchLocationSuggestions(q, isOrigin: false));
    } else {
      setState(() {
        destinationSuggestions.clear();
        showDestinationSuggestions = false;
      });
    }
  }

  Future<void> _searchLocationSuggestions(String query, {required bool isOrigin}) async {
    setState(() {
      if (isOrigin)
        isLoadingOriginSuggestions = true;
      else
        isLoadingDestinationSuggestions = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=eg&addressdetails=1',
      );
      final resp = await http.get(url, headers: {'User-Agent': 'SmartTransportApp/1.0'});
      if (resp.statusCode == 200) {
        final raw = json.decode(resp.body);
        if (raw is List) {
          final casted = raw
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          final suggestions = casted.map((m) => LocationSuggestion.fromJson(m)).toList();
          if (!mounted) return;
          setState(() {
            if (isOrigin) {
              originSuggestions = suggestions;
              showOriginSuggestions = originFocusNode.hasFocus && suggestions.isNotEmpty;
            } else {
              destinationSuggestions = suggestions;
              showDestinationSuggestions = destinationFocusNode.hasFocus && suggestions.isNotEmpty;
            }
          });
        }
      }
    } catch (_) {
      // ignore
    } finally {
      if (!mounted) return;
      setState(() {
        if (isOrigin)
          isLoadingOriginSuggestions = false;
        else
          isLoadingDestinationSuggestions = false;
      });
    }
  }

  void _selectLocationSuggestion(LocationSuggestion s, {required bool isOrigin}) {
    setState(() {
      if (isOrigin) {
        originController.text = s.displayName;
        originLat = s.latitude;
        originLng = s.longitude;
        showOriginSuggestions = false;
        originSuggestions.clear();
      } else {
        destinationController.text = s.displayName;
        destinationLat = s.latitude;
        destinationLng = s.longitude;
        showDestinationSuggestions = false;
        destinationSuggestions.clear();
      }
    });
  }

  Future<void> _autoDetectLocation() async {
    setState(() {
      isDetectingLocation = true;
      locationErrorMsg = '';
    });
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        originLat = pos.latitude;
        originLng = pos.longitude;
        await _reverseGeocode(pos.latitude, pos.longitude);
        fetchNearbyBuses();
      } else {
        setState(() => locationErrorMsg = 'Unable to access location. Please enter manually.');
      }
    } catch (e) {
      if (mounted) setState(() => locationErrorMsg = 'Location access failed: $e');
    } finally {
      if (mounted) setState(() => isDetectingLocation = false);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final resp = await http.get(url, headers: {'User-Agent': 'SmartTransportApp/1.0'});
      if (resp.statusCode == 200) {
        final map = Map<String, dynamic>.from(json.decode(resp.body));
        final name = map['display_name'] ?? 'Current Location';
        if (mounted) originController.text = name;
      } else {
        if (mounted)
          originController.text =
          'Current Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
      }
    } catch (_) {
      if (mounted)
        originController.text =
        'Current Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    }
  }

  Future<void> _refreshLocation() async => _autoDetectLocation();

  Future<void> fetchBuses() async {
    final o = originController.text.trim();
    final d = destinationController.text.trim();
    if (o.isEmpty || d.isEmpty) {
      setState(() => errorMsg = 'Please enter both origin and destination.');
      return;
    }
    setState(() {
      isLoading = true;
      errorMsg = '';
    });
    final url = Uri.parse(
      'http://smarttrackingapp.runasp.net/api/Bus/GetBusesFromOrginToDestination'
          '?origin=$o&destination=$d',
    );
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final raw = json.decode(resp.body);
        if (raw is List) {
          final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          setState(() => buses = list.map((m) => Bus.fromJson(m)).toList());
        } else {
          setState(() => errorMsg = 'Unexpected data format.');
        }
      } else {
        setState(() => errorMsg = 'Server error: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => errorMsg = 'Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchNearbyBuses() async {
    if (originLat == null || originLng == null) {
      setState(() => nearbyErrorMsg = 'Current location not available yet.');
      return;
    }
    setState(() {
      isLoadingNearby = true;
      nearbyErrorMsg = '';
    });
    final url = Uri.parse(
      'http://smarttrackingapp.runasp.net/api/Tracking/nearby'
          '?radiusMeters=1000&latitude=$originLat&longitude=$originLng',
    );
    try {
      final resp = await http.get(url, headers: {'accept': '*/*'});
      if (resp.statusCode == 200) {
        final raw = json.decode(resp.body);
        if (raw is List) {
          final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          setState(() =>
          nearbyBuses = list.map((m) => NearbyBus.fromJson(m)).toList());
        } else if (raw is Map) {
          final map = Map<String, dynamic>.from(raw);
          setState(() => nearbyBuses = [NearbyBus.fromJson(map)]);
        } else {
          setState(() => nearbyErrorMsg = 'Unexpected data format.');
        }
      } else {
        setState(() => nearbyErrorMsg = 'Server error: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => nearbyErrorMsg = 'Network error: $e');
    } finally {
      setState(() => isLoadingNearby = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColor.background,
    appBar: AppBar(
      backgroundColor: AppColor.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColor.primary, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('Select Address',
          style:
          TextStyle(color: AppColor.primary, fontSize: 20, fontWeight: FontWeight.w600)),
      centerTitle: true,
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLocationInput(),
            const SizedBox(height: 24),
            _buildSearchButton(),
            if (errorMsg.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(errorMsg),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      _buildLoadingWidget()
                    else if (buses.isNotEmpty) ...[
                      _buildSectionHeader('Search Results', Icons.search_rounded),
                      const SizedBox(height: 12),
                      ...buses.map((b) => _buildBusCard(b)),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionHeader('Nearby Buses', Icons.near_me_rounded,
                        onRefresh: fetchNearbyBuses),
                    const SizedBox(height: 12),
                    if (isLoadingNearby)
                      _buildLoadingWidget()
                    else if (nearbyErrorMsg.isNotEmpty)
                      _buildErrorMessage(nearbyErrorMsg)
                    else if (nearbyBuses.isEmpty)
                        _buildEmptyNearbyCard()
                      else
                        ...nearbyBuses.map((nb) => _buildNearbyBusCard(nb)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildLocationInput() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.accent.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Column(
          children: [
            Icon(Icons.my_location_rounded, color: AppColor.primary, size: 20),
            Container(
              width: 2,
              height: 32,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: AppColor.accent,
            ),
            Icon(Icons.location_on_rounded, color: AppColor.primary, size: 20),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: originFocusNode,
                      controller: originController,
                      style: TextStyle(color: AppColor.text, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: isDetectingLocation
                            ? 'Detecting location...'
                            : 'Your current location',
                        hintStyle: TextStyle(
                            color: AppColor.text.withValues(alpha: 0.6), fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                  if (isDetectingLocation)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _refreshLocation,
                      icon: Icon(Icons.my_location_rounded, color: AppColor.primary, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(28, 28),
                      ),
                    ),
                ],
              ),
              if (locationErrorMsg.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: AppColor.accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(locationErrorMsg,
                          style: TextStyle(color: AppColor.accent, fontSize: 11)),
                    ),
                  ],
                ),
              ],
              Divider(height: 1, color: AppColor.accent.withValues(alpha: 0.5)),
              TextField(
                focusNode: destinationFocusNode,
                controller: destinationController,
                style: TextStyle(color: AppColor.text, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Where to?',
                  hintStyle:
                  TextStyle(color: AppColor.text.withValues(alpha: 0.6), fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchButton() => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: fetchBuses,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_rounded, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Search Buses',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );

  Widget _buildSectionHeader(String title, IconData icon, {VoidCallback? onRefresh}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, color: AppColor.primary, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColor.primary)),
        ],
      ),
      if (onRefresh != null)
        IconButton(
          onPressed: onRefresh,
          icon: Icon(Icons.refresh_rounded, color: AppColor.text, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppColor.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(8),
          ),
        ),
    ],
  );

  Widget _buildBusCard(Bus bus) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.accent.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.directions_bus_rounded, size: 24, color: AppColor.primary),
              const SizedBox(height: 4),
              Text('${bus.id}',
                  style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColor.primary)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration:
                  BoxDecoration(color: AppColor.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(bus.origin,
                        style:
                        TextStyle(color: AppColor.text, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColor.accent),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration:
                  BoxDecoration(color: AppColor.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(bus.destination,
                        style:
                        TextStyle(color: AppColor.text, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildNearbyBusCard(NearbyBus bus) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.directions_bus_rounded, size: 24, color: AppColor.primary),
            const SizedBox(width: 8),
            Text('Bus #${bus.busId}',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16, color: AppColor.primary)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          bus.origin != null && bus.destination != null
              ? 'Route: ${bus.origin} → ${bus.destination}'
              : 'Route information not available',
          style: TextStyle(color: AppColor.text, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text('Location: (${bus.latitude.toStringAsFixed(4)}, ${bus.longitude.toStringAsFixed(4)})',
            style: TextStyle(color: AppColor.text.withValues(alpha: 0.7), fontSize: 12)),
        if (bus.driverId != null) ...[
          const SizedBox(height: 4),
          Text('Driver ID: ${bus.driverId}',
              style: TextStyle(color: AppColor.text.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ],
    ),
  );

  Widget _buildEmptyNearbyCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.accent.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        Icon(Icons.location_searching_rounded,
            size: 40, color: AppColor.text.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        Text('No nearby buses found',
            style: TextStyle(fontSize: 16, color: AppColor.text, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Try refreshing or check back later',
            style: TextStyle(fontSize: 12, color: AppColor.text.withValues(alpha: 0.7))),
      ],
    ),
  );

  Widget _buildErrorMessage(String message) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColor.accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColor.accent.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline_rounded, color: AppColor.text, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(color: AppColor.text, fontSize: 14))),
      ],
    ),
  );

  Widget _buildLoadingWidget() => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
        strokeWidth: 2,
      ),
    ),
  );
}
