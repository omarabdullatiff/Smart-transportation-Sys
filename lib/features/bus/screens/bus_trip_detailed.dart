import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/features/bus/screens/bus_schedule_page.dart';
import 'package:flutter_application_1/features/bus/screens/bus_tracking_screen.dart';

class BusTripDetailedScreen extends StatefulWidget {
  final String id;
  final String number;
  final String start;
  final String end;

  const BusTripDetailedScreen({
    super.key,
    required this.id,
    required this.number,
    required this.start,
    required this.end,
  });

  @override
  State<BusTripDetailedScreen> createState() => _BusTripDetailedScreenState();
}

class _BusTripDetailedScreenState extends State<BusTripDetailedScreen> {
  late Future<Map<String, dynamic>> tripFuture;

  @override
  void initState() {
    super.initState();
    tripFuture = fetchTrip(widget.id);
  }

  Future<Map<String, dynamic>> fetchTrip(String id) async {
    try {
      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Bus/$id/trip-details'),
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('API Response: $data'); // Debug logging
        return data;
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('API returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Network Error: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.primary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FutureBuilder<Map<String, dynamic>>(
          future: tripFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading trip details...'),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load trip details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            tripFuture = fetchTrip(widget.id);
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No trip details found'));
            }
            
            final trip = snapshot.data!;
            debugPrint('Trip data keys: ${trip.keys.toList()}'); // Debug logging
            
            // Use fallback values and multiple possible field names
            final busNumber = trip['busNumber']?.toString() ?? 
                             trip['number']?.toString() ?? 
                             widget.number;
            final origin = trip['origin']?.toString() ?? 
                          trip['start']?.toString() ?? 
                          trip['from']?.toString() ?? 
                          widget.start;
            final destination = trip['destination']?.toString() ?? 
                               trip['end']?.toString() ?? 
                               trip['to']?.toString() ?? 
                               widget.end;
            
            // Handle different possible structures for stops
            List stops = [];
            if (trip['stops'] != null) {
              stops = trip['stops'] is List ? trip['stops'] : [];
            } else if (trip['stations'] != null) {
              stops = trip['stations'] is List ? trip['stations'] : [];
            } else if (trip['routes'] != null) {
              stops = trip['routes'] is List ? trip['routes'] : [];
            }
            
            // If no stops from API, create default stops from origin and destination
            if (stops.isEmpty && origin.isNotEmpty && destination.isNotEmpty) {
              stops = [origin, destination];
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.directions_bus, color: AppColor.primary, size: 36),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              busNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 18, color: AppColor.primary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        origin,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 2,
                                  height: 18,
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.black,
                                        width: 1.2,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.circle, size: 14, color: AppColor.primary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        destination,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // AC Feature Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.ac_unit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'AC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wifi,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'WiFi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'COMFORT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: stops.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.route_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No stops available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Trip route: $origin → $destination',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: stops.length,
                        itemBuilder: (context, index) {
                          final isFirst = index == 0;
                          final isLast = index == stops.length - 1;
                          
                          // Extract only the stop name from stop object
                          String stopName = 'Unknown Stop';
                          final stop = stops[index];
                          
                          if (stop != null) {
                            if (stop is Map<String, dynamic>) {
                              // Extract the "stop" field from the stop object
                              stopName = stop['stop']?.toString() ?? 
                                        stop['name']?.toString() ?? 
                                        stop['stopName']?.toString() ?? 
                                        stop['stationName']?.toString() ?? 
                                        'Unknown Stop';
                            } else {
                              // If stop is already a string
                              stopName = stop.toString();
                            }
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: isFirst || isLast ? AppColor.primary : Colors.white,
                                        border: Border.all(color: AppColor.primary, width: 2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 40,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: AppColor.primary,
                                              width: 2,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: (isFirst || isLast) 
                                        ? AppColor.primary.withValues(alpha: 0.1)
                                        : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (isFirst || isLast) 
                                          ? AppColor.primary.withValues(alpha: 0.3)
                                          : Colors.grey.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      stopName,
                                      style: TextStyle(
                                        color: (isFirst || isLast) ? AppColor.primary : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: (isFirst || isLast) ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
                
                // Price section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip Price',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '25 LE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Fixed Rate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 12),
                  child: Row(
                    children: [
                                                                    Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusTrackingScreen(
                                  busId: widget.id,
                                  showRouteOnStart: true,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Show bus on map",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BusSchedulePage(busId: widget.id)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'View Schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
