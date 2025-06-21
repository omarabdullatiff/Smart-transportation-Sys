import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TarcTrackingPage extends StatelessWidget {
  const TarcTrackingPage({super.key});

  final LatLng center = const LatLng(30.0444, 31.2357); // Cairo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          //Temporary LIVE MAP till real  api  
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.directions_bus, color: Colors.amber, size: 30),
                        ),
                      ],
                    )

                  ],
                ),
                SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF9FA122)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.fullscreen, color: Colors.grey[700]),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Expanded(child: RouteDetails())
        ],
      ),
    );
  }
}

class RouteDetails extends StatelessWidget {
  const RouteDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("From", style: TextStyle(color: Colors.grey)),
          const Text("5th settlement", style: TextStyle(fontSize: 16)),
          const Divider(),
          const Text("To", style: TextStyle(color: Colors.grey)),
          const Text("Heliopolis", style: TextStyle(fontSize: 16)),
          const Divider(height: 32),
          const Text("TARC arrival time", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Color(0xFF9FA122)),
              const SizedBox(width: 8),
              const Text("St", style: TextStyle(color: Colors.grey)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("ETA",
                      style: TextStyle(
                        color: Color(0xFF9FA122),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )
                  ),
                  Text("5 min", style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("TARC station stops", style: TextStyle(fontSize: 18)),
          const Text("TARC location", style: TextStyle(color: Colors.grey)),
          const Divider(),
          _buildStop("completed", Colors.amber),
          const Divider(),
          _buildStop("completed", Colors.amber),
          const Divider(),
          _buildStop("On the way", Colors.red),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9FA122),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Complete", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStop(String status, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(status, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}