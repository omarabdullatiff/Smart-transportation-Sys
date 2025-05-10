import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/booking/screens/booking_screen.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';

class BusListView extends StatefulWidget {
  const BusListView({super.key});

  @override
  _BusListViewState createState() => _BusListViewState();
}

class _BusListViewState extends State<BusListView> {
  int? selectedBusIndex;

  final List<Map<String, String>> buses = [
    {'number': '505', 'start': '5th Settlement', 'end': 'Heliopolis'},
    {'number': '400', 'start': 'Nasr City', 'end': 'Downtown'},
    {'number': '300', 'start': 'Maadi', 'end': 'Giza'},
    {'number': '200', 'start': '6th October', 'end': 'Zamalek'},
    {'number': '101', 'start': 'New Cairo', 'end': 'Alexandria'},
    {'number': '202', 'start': 'Giza', 'end': 'Luxor'},
    {'number': '303', 'start': 'Cairo', 'end': 'Aswan'},
    {'number': '404', 'start': 'Sharm El Sheikh', 'end': 'Hurghada'},
  ];

  void _navigateToBookingScreen(BuildContext context, Map<String, String> bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(bus: bus),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the text above the list of buses
            Center(
              child: Text(
                'Bus in your area',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
                height: 10), // Add some spacing between the text and the list
            Expanded(
              child: ListView.builder(
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBusIndex = index;
                      });
                      _navigateToBookingScreen(context, buses[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedBusIndex == index
                              ? Colors.blue[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedBusIndex == index
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.directions_bus,
                            color: selectedBusIndex == index
                                ? Colors.blue
                                : Colors.grey[700],
                            size: 30,
                          ),
                          title: Text(
                            buses[index]['number']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedBusIndex == index
                                  ? Colors.blue
                                  : Colors.grey[700],
                            ),
                          ),
                          subtitle: Text(
                            '${buses[index]['start']} → ${buses[index]['end']}',
                            style: TextStyle(
                              color: selectedBusIndex == index
                                  ? Colors.blue
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
