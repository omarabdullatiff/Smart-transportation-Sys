import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusTrackingScreen extends StatelessWidget {
  final List<Map<String, dynamic>> busStops = [
    {'name': 'A', 'lat': 30.0444, 'lng': 31.2357},
    {'name': 'B', 'lat': 30.0450, 'lng': 31.2365},
    {'name': 'C', 'lat': 30.0460, 'lng': 31.2375},
    {'name': 'G', 'lat': 30.0470, 'lng': 31.2385},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 170, 173, 151),
                
              ),
              child: Text(
                'Omar Abdullatif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Lost'),
                    onTap: () {
                      Navigator.pushNamed(context, '/loses');
                    },
                  ),
                  ListTile(
                    title: const Text('Found'),
                    onTap: () {
                      Navigator.pushNamed(context, '/founditem');
                    },
                  ),
                  ListTile(
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pushNamed(context, '/setting');
                    },
                  ),
                  ListTile(
                    title: const Text('Help'),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('About us'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Privacy policy'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Terms and conditions'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clear session or token data
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                icon: const Icon(
                  Icons.logout,
                  size: 10,

                  ),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 167, 67, 17),
                  foregroundColor: Colors.white,
                
                  
                ),
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(30.0444, 31.2357),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: busStops.map((stop) {
                  return Marker(
                    width: 60.0,
                    height: 60.0,
                    point: LatLng(stop['lat'], stop['lng']),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            stop['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.directions_bus,
                          color: Colors.yellow,
                          size: 30,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 40,
            right: 40,
            child: Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/booking');
                  },
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
