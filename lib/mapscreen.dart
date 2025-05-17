import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Account/getCurrentUser'),
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('User Data Response: $responseData');
        setState(() {
          userData = responseData;
          isLoading = false;
        });
      } else {
        print('Error Response: ${response.body}');
        await prefs.clear();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load user data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColor.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['name'] ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userData?['email'] ?? 'email@example.com',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            ListTile(
              title: Text('Lost'),
              onTap: () {
                Navigator.pushNamed(context,'/loses');
              },
            ),
            ListTile(
              title: Text('Found'),
              onTap: () {
                Navigator.pushNamed(context,'/founditem');
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/setting');
              },
            ),
            ListTile(
              title: Text('Help'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            Divider(),
            ListTile(
              title: Text('About us'),
              onTap: () {
                Navigator.pushNamed(context, '/seatselect');
              },
            ),
            ListTile(
              title: Text('Privacy policy'),
              onTap: () {
                // Handle the tap
              },
            ),
            ListTile(
              title: Text('Terms and conditions'),
              onTap: () {
                // Handle the tap
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Map Screen Content'),
      ),
    );
  }
}