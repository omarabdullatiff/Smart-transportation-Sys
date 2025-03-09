import 'package:flutter/material.dart';
//import 'package:flutter_application_1/BookingScreen.dart';
import 'package:flutter_application_1/BusList.dart';
import 'package:flutter_application_1/Forget_pass.dart';
import 'package:flutter_application_1/app_color.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/loses.dart';
import 'package:flutter_application_1/mapscreen.dart';
import 'package:flutter_application_1/profilescreen.dart';
import 'package:flutter_application_1/seat_select_screan.dart';
import 'package:flutter_application_1/selectaddress.dart';
import 'package:flutter_application_1/setting_screen.dart';
import 'package:flutter_application_1/signup.dart';

void main() {
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false ,
       theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:AppColor.primary, // Primary color
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Enable Material 3
      ),
      initialRoute: "/",
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/forgetpass':(context) => const Forgetpass(),
        '/booking':(context) => const SelectAddressPage(),
        '/map':(context) => const Mapscreen(),
        '/loses':(context) =>  ReportItemPage(),
        '/buslist':(context) =>  BusListView(),
        '/setting':(context) =>  SettingsScreen(),
        '/seatselect':(context) =>  SeatSelectionScreen(),
        '/profile':(context) =>  ProfileEditScreen(),

        
      },
    );
  }
}
