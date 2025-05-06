import 'package:flutter/material.dart';
class Mapscreen extends StatelessWidget {
  const Mapscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // Hamburger menu icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
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
                color: const Color.fromARGB(255, 159, 181, 13),
              ),
              child: Text(
                'Omar Abdullatif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Lost'),
              onTap: () {
                Navigator.pushNamed(context,'/founditem');

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
               Navigator.pushNamed(context, '/setting');;
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