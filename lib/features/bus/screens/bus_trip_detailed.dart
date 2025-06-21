import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// استيراد صفحة الجدول من ملفها الأصلي
import 'package:flutter_application_1/features/bus/screens/bus_schedule_page.dart';

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
    final response = await http.get(
      Uri.parse('http://smarttrackingapp.runasp.net/api/Bus/$id/trip-details'),
      headers: {'accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load trip details');
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
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load trip details'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No trip details found'));
            }
            final trip = snapshot.data!;
            final busNumber = trip['busNumber']?.toString() ?? '';
            final origin = trip['origin']?.toString() ?? '';
            final destination = trip['destination']?.toString() ?? '';
            final List stops = trip['stops'] ?? [];

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
                  child: Row(
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
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: stops.length,
                    itemBuilder: (context, index) {
                      final isFirst = index == 0;
                      final isLast = index == stops.length - 1;
                      return Row(
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
                                  height: 32,
                                  margin: const EdgeInsets.symmetric(vertical: 2),
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
                            child: Text(
                              stops[index],
                              style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // مؤقتاً طباعة رسالة في الكونسول
                            debugPrint("Show bus on map clicked");
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
                              MaterialPageRoute(builder: (context) => const BusSchedulePage()),
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
