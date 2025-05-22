import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/booking/screens/booking_screen.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/features/bus/widgets/bus_card.dart';
import 'package:flutter_application_1/features/bus/services/bus_service.dart';

class BusListView extends StatelessWidget {
  const BusListView({super.key});

  void _onBusTap(BuildContext context, Map<String, String> bus) {
    // You can add navigation or other logic here if needed, but removed fetchBusAbstract and pop-up logic.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'All Buses',
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        automaticallyImplyLeading: false,
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
                onTap: () => _onBusTap(context, {
                  'number': bus['number']?.toString() ?? '',
                  'start': bus['org']?.toString() ?? '',
                  'end': bus['dest']?.toString() ?? '',
                }),
              );
            },
          );
        },
      ),
    );
  }
}
