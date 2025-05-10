import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/bus/screens/bus_list_screen.dart';
import 'package:flutter_application_1/features/auth/screens/forget_password_screen.dart';
import 'package:flutter_application_1/features/auth/screens/change_password_screen.dart';
import 'package:flutter_application_1/features/lost_items/screens/found_items_screen.dart';
import 'package:flutter_application_1/features/auth/screens/home_screen.dart';
import 'package:flutter_application_1/features/bus/screens/tracking_screen.dart';
import 'package:flutter_application_1/features/auth/screens/login_screen.dart';
import 'package:flutter_application_1/features/lost_items/screens/lost_items_screen.dart';
import 'package:flutter_application_1/features/bus/screens/bus_tracking_screen.dart';
import 'package:flutter_application_1/features/profile/screens/profile_screen.dart';
import 'package:flutter_application_1/features/bus/screens/seat_selection_screen.dart';
import 'package:flutter_application_1/features/booking/screens/select_address_screen.dart';
import 'package:flutter_application_1/features/profile/screens/settings_screen.dart';
import 'package:flutter_application_1/features/auth/screens/signup_screen.dart';
import 'package:flutter_application_1/features/auth/screens/verification_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPass = '/forgetpass';
  static const String booking = '/booking';
  static const String loses = '/loses';
  static const String busList = '/buslist';
  static const String setting = '/setting';
  static const String seatSelect = '/seatselect';
  static const String profile = '/profile';
  static const String verification = '/virscreen';
  static const String foundItem = '/founditem';
  static const String newMap = '/newmap';
  static const String track = '/track';
  static const String changePass = '/changepass';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const Login(),
      signup: (context) => const Signup(),
      forgetPass: (context) => const Forgetpass(),
      booking: (context) => const SelectAddressPage(),
      loses: (context) => ReportItemPage(),
      busList: (context) => BusListView(),
      setting: (context) => SettingsScreen(),
      seatSelect: (context) => SeatSelectionScreen(),
      profile: (context) => EditProfileScreen(),
      verification: (context) => const VerificationScreen(),
      foundItem: (context) => FoundItemsScreen(),
      newMap: (context) => BusTrackingScreen(),
      track: (context) => TarcTrackingPage(),
      changePass: (context) => const NewPasswordScreen(email: '', code: ''),
    };
  }
} 