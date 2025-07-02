import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/features/bus/screens/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  final Map<String, bool> _bookedSeats = {
    'A2': true,
    'B3': true,
    'C1': true,
    'D4': true,
  };

  // Nearby buses
  List<NearbyBus> nearbyBuses = [];
  bool isLoadingNearbyBuses = false;
  String nearbyErrorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetchNearbyBuses();
  }

  Future<void> _fetchNearbyBuses() async {
    setState(() {
      isLoadingNearbyBuses = true;
      nearbyErrorMsg = '';
    });

    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos == null) {
        setState(() {
          nearbyErrorMsg = 'Unable to access location for nearby buses.';
          isLoadingNearbyBuses = false;
        });
        return;
      }

      final url = Uri.parse(
        'http://smarttrackingapp.runasp.net/api/Tracking/nearby?latitude=${pos.latitude}&longitude=${pos.longitude}&radiusMeters=1000'
      );

      final response = await http.get(
        url,
        headers: {'accept': '*/*'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            nearbyBuses = data.map((e) => NearbyBus.fromJson(e as Map<String, dynamic>)).toList();
          });
        } else if (data is Map) {
          setState(() {
            nearbyBuses = [NearbyBus.fromJson(data as Map<String, dynamic>)];
          });
        } else {
          setState(() => nearbyErrorMsg = 'Unexpected data format.');
        }
      } else if (response.statusCode == 404) {
        setState(() => nearbyErrorMsg = 'No buses found in your area.');
      } else {
        setState(() => nearbyErrorMsg = 'Unable to fetch nearby buses. Please try again later.');
      }
    } catch (e) {
      setState(() => nearbyErrorMsg = 'Connection error. Please check your internet and try again.');
    } finally {
      setState(() => isLoadingNearbyBuses = false);
    }
  }

  Future<void> _refreshNearbyBuses() async {
    await _fetchNearbyBuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose your seat',
          style: TextStyle(
            color: AppColor.primaryLight
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshNearbyBuses,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Nearby Buses Section
            _buildNearbyBusesSection(),
            const SizedBox(height: 20),
            
            _buildLegend(),
            const SizedBox(height: 30),
            _buildSeatGrid(),
            const SizedBox(height: 20),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'helwan  - -> 5th settlement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '1 - Jan - 2025 | Wednesday',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyBusesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.near_me_rounded, color: AppColor.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Nearby Buses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                                 const Spacer(),
                 Text(
                   'Within 1km',
                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                     color: AppColor.text.withValues(alpha: 0.7),
                   ),
                 ),
              ],
            ),
            const SizedBox(height: 12),
            
                         if (isLoadingNearbyBuses)
               _buildLoadingWidget()
             else if (nearbyErrorMsg.isNotEmpty)
               _buildErrorMessage(nearbyErrorMsg)
             else if (nearbyBuses.isEmpty)
               _buildEmptyNearbyCard()
             else
               _buildNearbyBusList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
                         Text(
               'Finding nearby buses...',
               style: TextStyle(
                 color: AppColor.text.withValues(alpha: 0.7),
                 fontSize: 14,
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColor.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColor.text,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNearbyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_searching_rounded,
            size: 32,
            color: AppColor.text.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No nearby buses found',
            style: TextStyle(
              fontSize: 14,
              color: AppColor.text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try refreshing or check back later',
            style: TextStyle(
              fontSize: 12,
              color: AppColor.text.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyBusList() {
    return Column(
      children: nearbyBuses.map((bus) => _buildNearbyBusCard(bus)).toList(),
    );
  }

  Widget _buildNearbyBusCard(NearbyBus bus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Icon(Icons.directions_bus_rounded, size: 20, color: AppColor.primary),
                const SizedBox(height: 2),
                Text(
                  '${bus.busId}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.near_me_rounded, color: AppColor.primary, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby Bus',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                if (bus.origin != null && bus.destination != null) ...[
                  Text(
                    'From: ${bus.origin}',
                    style: TextStyle(color: AppColor.text, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'To: ${bus.destination}',
                    style: TextStyle(color: AppColor.text, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    'Route info not available',
                    style: TextStyle(
                      color: AppColor.text.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Navigate to tracking or more details
              Navigator.pushNamed(context, '/track');
            },
            icon: Icon(
              Icons.directions_rounded,
              color: AppColor.primary,
              size: 18,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColor.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(28, 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.green, 'Available'),
        _buildLegendItem(Colors.grey, 'Booked'),
        _buildLegendItem(Colors.blue, 'Your seat'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 50,
        crossAxisSpacing: 20,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        final row = String.fromCharCode(65 + (index ~/ 4));
        final number = (index % 4) + 1;
        final seat = '$row$number';
        final isBooked = _bookedSeats.containsKey(seat);
        final isSelected = _selectedSeats.contains(seat);

        return _buildSeat(seat, isBooked, isSelected);
      },
    );
  }

  Widget _buildSeat(String seat, bool isBooked, bool isSelected) {
    return GestureDetector(
      onTap: isBooked ? null : () => _toggleSeat(seat),
      child: Container(
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey
              : isSelected
                  ? Colors.blue
                  : Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seat,
            style: TextStyle(
              color: isBooked || isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColor.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _selectedSeats.isEmpty ? null : () {
        Navigator.pushNamed(context, '/track');
      },
      child: Text(
        _selectedSeats.isEmpty 
          ? 'Select seats to continue' 
          : 'Confirm (${_selectedSeats.length} seat${_selectedSeats.length == 1 ? '' : 's'})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _toggleSeat(String seat) {
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else {
        _selectedSeats.add(seat);
      }
    });
  }
}