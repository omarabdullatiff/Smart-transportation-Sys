import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/bus/screens/bus_list_screen.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/common_widgets.dart';

class SelectAddressPage extends StatelessWidget {
  const SelectAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
         leading: IconButton(
        icon: Icon(Icons.arrow_back, color:AppColor.primaryDark),
         onPressed: () => Navigator.of(context).pop(),
      ),
        title: Text('Select Address',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            locationInput(),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildIconButton(Icons.home, 'Home'),
                buildIconButton(Icons.work, 'Work'),
                buildIconButton(Icons.star, 'Favorites'),
              ],
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  //MaterialPageRoute(builder: (context) => ChooseOnMapPage());
                  Navigator.pushNamed(context, '/newmap');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map, // Use the map icon
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    SizedBox(width: 28),
                    Text(
                      'Choose on map',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            BusListView(),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

Widget locationInput() {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Column(
          children: [
            Icon(Icons.location_pin, color: Colors.green),
            Container(
              width: 2,
              height: 25,
              color: Colors.grey[400],
            ),
            Icon(Icons.location_pin, color: Colors.blue),
          ],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Your Current location',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1, color: Colors.grey),
              TextField(
                decoration: InputDecoration(
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
