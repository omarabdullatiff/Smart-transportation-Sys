import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TarcTrackingPage extends StatelessWidget {
  TarcTrackingPage({Key? key}) : super(key: key);

  final LatLng center = LatLng(30.0444, 31.2357); // Example: Cairo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: Column(
        children: [
          // LIVE MAP (no API)
          Container(
            height: 250,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: center,
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.directions_bus, color: Colors.amber, size: 30),
                        ),
                      ],
                    )

                  ],
                ),
                SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xFF9FA122)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Spacer(),
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
          // OTHER UI ELEMENTS
          Expanded(child: RouteDetails())
        ],
      ),
    );
  }
}

class RouteDetails extends StatelessWidget {
  const RouteDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("From", style: TextStyle(color: Colors.grey)),
          Text("5th settlement", style: TextStyle(fontSize: 16)),
          Divider(),
          Text("To", style: TextStyle(color: Colors.grey)),
          Text("Heliopolis", style: TextStyle(fontSize: 16)),
          Divider(height: 32),
          Text("TARC arrival time", style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.directions_bus, color: Color(0xFF9FA122)),
              SizedBox(width: 8),
              Text("St", style: TextStyle(color: Colors.grey)),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("ETA",
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
          SizedBox(height: 16),
          Text("TARC station stops", style: TextStyle(fontSize: 18)),
          Text("TARC location", style: TextStyle(color: Colors.grey)),
          Divider(),
          _buildStop("completed", Colors.amber),
          Divider(),
          _buildStop("completed", Colors.amber),
          Divider(),
          _buildStop("On the way", Colors.red),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9FA122),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Complete", style: TextStyle(fontSize: 18)),
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
        SizedBox(width: 12),
        Text(status, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}