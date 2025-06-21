import 'package:flutter/material.dart';

class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({super.key});

  @override
  State<BusSchedulePage> createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  bool isGo = true;

  final Map<String, List<String>> schedule = {
    
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
  Widget build(BuildContext context) {
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
            const Expanded(
              child: Text(
                '575 Schedule',
                style: TextStyle(fontWeight: FontWeight.bold),
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
      body: ListView(
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
    );
  }
}
