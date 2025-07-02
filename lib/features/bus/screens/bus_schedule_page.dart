import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusSchedulePage extends StatefulWidget {
  final String? busId;
  
  const BusSchedulePage({super.key, this.busId});

  @override
  State<BusSchedulePage> createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  bool isGo = true;
  bool isLoading = false;
  String errorMessage = '';
  List<String> apiStops = [];

  // Static time schedules (keeping times static as requested)
  final List<String> morningTimes = ['06:10', '06:30', '06:50', '07:10', '07:30', '07:50'];
  final List<String> midMorningTimes = ['08:10', '08:30', '09:00', '09:30', '10:00', '10:30'];
  final List<String> earlyTimes = ['06:05', '06:25', '06:45', '07:05', '07:25', '07:45'];
  final List<String> lateTimes = ['08:05', '08:25', '08:50', '09:15', '09:40', '10:00'];

  // Fallback static schedule (in case API fails)
  final Map<String, List<String>> fallbackSchedule = {
    'To 6th October Street': ['06:10', '06:30', '06:50', '07:10', '07:30', '07:50', '08:10', '08:30', '09:00', '09:30', '10:00', '10:30'],
    'Sheikh zayed': ['06:10', '06:30', '06:50', '07:10', '07:30', '07:50', '08:10', '08:30', '09:00', '09:30', '10:00', '10:30'],
    'Downtown Cairo': ['06:10', '06:30', '06:50', '07:10', '07:30', '07:50', '08:10', '08:30', '09:00', '09:30', '10:00', '10:30'],
    '26th Of July Axis': ['06:05', '06:25', '06:45', '07:05', '07:25', '07:45', '08:05', '08:25', '08:50', '09:15', '09:40', '10:00'],
    'Ahmed Orabi Street': ['06:15', '06:35', '06:55', '07:15', '07:35', '07:55', '08:20', '08:40', '09:10', '09:40', '10:10', '10:40'],
    'Al Moshir Tantawy Axis': ['06:20', '06:40', '07:00', '07:20', '07:40', '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00'],
    'Airport Street': ['06:25', '06:45', '07:05', '07:25', '07:50', '08:15', '08:40', '09:05', '09:30', '09:55', '10:20', '10:45'],
    'Salah Salem Street': ['06:30', '06:50', '07:10', '07:30', '07:50', '08:10', '08:30', '08:50', '09:10', '09:30', '09:50', '10:10'],
    'Teleperformance': ['06:35', '06:55', '07:15', '07:35', '07:55', '08:15', '08:35', '08:55', '09:15', '09:35', '09:55', '10:15'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.busId != null) {
      _fetchBusStops();
    }
  }

  Future<void> _fetchBusStops() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Bus/${widget.busId}/trip-details'),
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Schedule API Response: $data');
        
        List stops = [];
        if (data['stops'] != null) {
          stops = data['stops'] is List ? data['stops'] : [];
        } else if (data['stations'] != null) {
          stops = data['stations'] is List ? data['stations'] : [];
        } else if (data['routes'] != null) {
          stops = data['routes'] is List ? data['routes'] : [];
        }
        
        // Extract stop names
        List<String> stopNames = [];
        for (var stop in stops) {
          String stopName = 'Unknown Stop';
          if (stop != null) {
            if (stop is Map<String, dynamic>) {
              stopName = stop['stop']?.toString() ?? 
                        stop['name']?.toString() ?? 
                        stop['stopName']?.toString() ?? 
                        stop['stationName']?.toString() ?? 
                        'Unknown Stop';
            } else {
              stopName = stop.toString();
            }
          }
          if (stopName.isNotEmpty && stopName != 'Unknown Stop') {
            stopNames.add(stopName);
          }
        }
        
        setState(() {
          apiStops = stopNames;
          isLoading = false;
        });
        
        if (apiStops.isEmpty) {
          setState(() {
            errorMessage = 'No stops found for this bus';
          });
        }
      } else {
        throw Exception('API returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching bus stops: $e');
      setState(() {
        errorMessage = 'Failed to load schedule data';
        isLoading = false;
      });
    }
  }

  Map<String, List<String>> _buildSchedule() {
    if (apiStops.isNotEmpty) {
      // Use API data with static times
      Map<String, List<String>> schedule = {};
      for (int i = 0; i < apiStops.length; i++) {
        String stopName = apiStops[i];
        // Vary the times slightly for different stops
        List<String> times;
        switch (i % 4) {
          case 0:
            times = morningTimes + midMorningTimes;
            break;
          case 1:
            times = earlyTimes + lateTimes;
            break;
          case 2:
            times = ['06:15', '06:35', '06:55', '07:15', '07:35', '07:55', '08:20', '08:40', '09:10', '09:40', '10:10', '10:40'];
            break;
          default:
            times = ['06:20', '06:40', '07:00', '07:20', '07:40', '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00'];
        }
        schedule[stopName] = times;
      }
      return schedule;
    } else {
      // Use fallback schedule
      return fallbackSchedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _buildSchedule();
    final List<MapEntry<String, List<String>>> orderedSchedule =
        isGo ? schedule.entries.toList() : schedule.entries.toList().reversed.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.busId != null 
                  ? 'Bus ${widget.busId} Schedule'
                  : 'Bus Schedule',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isGo = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isGo ? Colors.black : Colors.white,
                foregroundColor: isGo ? Colors.white : Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Go'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isGo = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !isGo ? Colors.black : Colors.white,
                foregroundColor: !isGo ? Colors.white : Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Return'),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading schedule...'),
                ],
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.busId != null) {
                            _fetchBusStops();
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (widget.busId != null && apiStops.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing live schedule for Bus ${widget.busId} (${apiStops.length} stops)',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        children: orderedSchedule.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              title: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB2C248),
                                  fontSize: 16,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: entry.value.map((time) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          time,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }
}
