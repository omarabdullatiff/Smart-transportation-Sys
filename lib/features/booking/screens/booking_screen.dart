import 'package:flutter/material.dart';


class BookingScreen extends StatelessWidget {
  final Map<String, String> bus;

  const BookingScreen({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Bus'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bus Number: ${bus['number']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Route: ${bus['start']} → ${bus['end']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add booking logic here
                Navigator.pushNamed(context, '/seatselect');
              },
              child: Text('Choose your seat'),
            ),
          ],
        ),
      ),
    );
  }
}
