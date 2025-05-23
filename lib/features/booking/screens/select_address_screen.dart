import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  List<Bus> buses = [];
  bool isLoading = false;
  String errorMsg = '';

  Future<void> fetchBuses() async {
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      setState(() => errorMsg = 'Please enter both origin and destination.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    final url = Uri.parse(
        'http://smarttrackingapp.runasp.net/api/Bus/GetBusesFromOrginToDestination?origin=$origin&destination=$destination');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            buses = data.map((e) => Bus.fromJson(e)).toList();
          });
        } else {
          setState(() => errorMsg = 'Unexpected data format.');
        }
      } else {
        setState(() => errorMsg = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMsg = 'Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Select Address',
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          locationInput(),
          const SizedBox(height: 25),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconTextButton(icon: Icons.home, text: 'Home'),
              IconTextButton(icon: Icons.work, text: 'Work'),
              IconTextButton(icon: Icons.star, text: 'Favorites'),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: fetchBuses,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.grey[800], size: 20),
                  const SizedBox(width: 28),
                  const Text(
                    'Search Buses',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (errorMsg.isNotEmpty)
            Text(errorMsg,
                style: const TextStyle(color: Colors.red, fontSize: 14)),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : buses.isEmpty
                ? const Center(child: Text("No buses found."))
                : ListView.builder(
              itemCount: buses.length,
              itemBuilder: (context, index) =>
                  BusCard(bus: buses[index]),
            ),
          ),
        ],
      ),
    ),
  );

  Widget locationInput() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Column(
          children: [
            const Icon(Icons.location_pin, color: Colors.green),
            Container(width: 2, height: 25, color: Colors.grey[400]),
            const Icon(Icons.location_pin, color: Colors.blue),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              TextField(
                controller: originController,
                decoration: const InputDecoration(
                  hintText: 'Your Current location',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(
                  hintText: 'Where to ?',
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconTextButton({required this.icon, required this.text, super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Colors.grey[800]),
      Text(text),
    ],
  );
}

class BusCard extends StatelessWidget {
  final Bus bus;

  const BusCard({super.key, required this.bus});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.directions_bus, size: 28, color: Colors.black87),
            const SizedBox(height: 4),
            Text('${bus.id}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 24, color: Colors.grey),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bus.origin,
                  style: const TextStyle(color: Colors.black87),
                  overflow: TextOverflow.ellipsis),
              Text(bus.destination,
                  style: const TextStyle(color: Colors.black87),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}
