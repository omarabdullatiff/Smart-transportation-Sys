import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:flutter_application_1/profilescreen.dart';
import 'package:flutter_application_1/seat_select_screan.dart';
import 'package:flutter_application_1/selectaddress.dart';
import 'package:flutter_application_1/setting_screen.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final token = prefs.getString('auth_token');

  runApp(MyApp(isLoggedIn: isLoggedIn && token != null));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {  // Only initialize deep linking on mobile platforms
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null &&
            uri.path == '/reset' &&
            uri.queryParameters.containsKey('email') &&
            uri.queryParameters.containsKey('code')) {
          final email = uri.queryParameters['email']!;
          final code = uri.queryParameters['code']!;
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => NewPasswordScreen(email: email, code: code),
            ),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: widget.isLoggedIn ? '/newmap' : '/',
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
        // Keep this for non-deeplink navigation
        '/changepass': (context) => const NewPasswordScreen(email: '', code: ''),
      },
    );
  }
}
