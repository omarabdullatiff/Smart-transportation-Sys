import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/screens/login_screen.dart';
import 'package:flutter_application_1/features/auth/screens/signup_screen.dart';
import 'package:flutter_application_1/features/auth/screens/verification_screen.dart';
import 'package:flutter_application_1/features/auth/screens/forget_password_screen.dart';
import 'package:flutter_application_1/features/auth/screens/change_password_screen.dart';
import 'package:flutter_application_1/features/auth/screens/home_screen.dart';
import 'package:flutter_application_1/features/bus/screens/bus_tracking_screen.dart';
import 'package:flutter_application_1/features/bus/screens/bus_list_screen.dart';
import 'package:flutter_application_1/features/booking/screens/select_address_screen.dart';
import 'package:flutter_application_1/features/lost_items/screens/lost_items_screen.dart';
import 'package:flutter_application_1/features/lost_items/screens/found_items_screen.dart';
import 'package:flutter_application_1/features/profile/screens/profile_screen.dart';
import 'package:flutter_application_1/features/profile/screens/settings_screen.dart';
import 'package:flutter_application_1/features/bus/screens/seat_selection_screen.dart';
import 'package:flutter_application_1/features/bus/screens/tracking_screen.dart';
import 'package:flutter_application_1/features/admin/screens/admin_dashboard_screen.dart';

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
  static const String verification = '/verification';
  static const String foundItem = '/founditem';
  static const String newMap = '/map';
  static const String track = '/track';
  static const String changePass = '/changepass';
  static const String debugResetPassword = '/debug_reset';
  static const String adminDashboard = '/admin';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const Login(),
      signup: (context) => const Signup(),
      forgetPass: (context) => const Forgetpass(),
      booking: (context) => const SelectAddressPage(),
      loses: (context) => ReportItemPage(),
      busList: (context) => const BusListView(),
      setting: (context) => const SettingsScreen(),
      seatSelect: (context) => const SeatSelectionScreen(),
      profile: (context) => const EditProfileScreen(),
      verification: (context) => const VerificationScreen(),
      foundItem: (context) => const FoundItemsScreen(),
      newMap: (context) => const BusTrackingScreen(),
      track: (context) => const TarcTrackingPage(),
      changePass: (context) => const NewPasswordScreen(email: '', code: ''),
      debugResetPassword: (context) => const NewPasswordScreen(email: 'test@example.com', code: '123456'),
      adminDashboard: (context) => const AdminDashboardScreen(),
    };
  }
} 