import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/features/bus/widgets/bus_card.dart';
import 'package:flutter_application_1/features/bus/services/bus_service.dart';
import 'package:flutter_application_1/features/bus/screens/bus_trip_detailed.dart';

class BusListView extends StatelessWidget {
  const BusListView({super.key});

  void _onBusTap(BuildContext context, Map<String, dynamic> bus) {
    final busId = bus['id']?.toString() ?? bus['number']?.toString() ?? '';
    final busNumber = bus['number']?.toString() ?? '';
    final origin = bus['org']?.toString() ?? bus['origin']?.toString() ?? '';
    final destination = bus['dest']?.toString() ?? bus['destination']?.toString() ?? '';
    
    debugPrint('Bus data: $bus'); // Debug logging
    debugPrint('Navigating with: id=$busId, number=$busNumber, start=$origin, end=$destination');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusTripDetailedScreen(
          id: busId,
          number: busNumber,
          start: origin,
          end: destination,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.primary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Buses',
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: BusService.fetchAllBuses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load buses'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No buses found'));
          }
          final buses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              return BusCard(
                number: bus['number']?.toString() ?? '',
                start: bus['org']?.toString() ?? '',
                end: bus['dest']?.toString() ?? '',
                onTap: () => _onBusTap(context, bus),
              );
            },
          );
        },
      ),
    );
  }
}
