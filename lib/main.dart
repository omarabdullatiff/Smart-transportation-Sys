import 'package:flutter/material.dart';
import 'package:flutter_application_1/BusList.dart';
import 'package:flutter_application_1/Forget_pass.dart';
import 'package:flutter_application_1/app_color.dart';
import 'package:flutter_application_1/change_pass.dart';
import 'package:flutter_application_1/found_items.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'package:flutter_application_1/image/tracking_screen.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/loses.dart';
import 'package:flutter_application_1/map.dart';
//import 'package:flutter_application_1/mapscreen.dart';
import 'package:flutter_application_1/profilescreen.dart';
import 'package:flutter_application_1/seat_select_screan.dart';
import 'package:flutter_application_1/selectaddress.dart';
import 'package:flutter_application_1/setting_screen.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/newmap' : '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/forgetpass': (context) => const Forgetpass(),
        '/booking': (context) => const SelectAddressPage(),
        '/loses': (context) => ReportItemPage(),
        '/buslist': (context) => BusListView(),
        '/setting': (context) => SettingsScreen(),
        '/seatselect': (context) => SeatSelectionScreen(),
        '/profile': (context) => EditProfileScreen(),
        '/virscreen': (context) => const VerificationScreen(),
        '/founditem': (context) => FoundItemsScreen(),
        '/newmap': (context) => BusTrackingScreen(),
        '/track': (context) => TarcTrackingPage(),
        '/changepass': (context) => NewPasswordScreen(),
      },
    );
  }
}
