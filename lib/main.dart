import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/features/auth/screens/change_password_screen.dart';
import 'package:flutter_application_1/core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:io' show Platform;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global variable to store deep link data
Uri? initialDeepLink;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final token = prefs.getString('auth_token');

  // Handle initial deep link
  if (!kIsWeb) {
    try {
      final appLinks = AppLinks();
      initialDeepLink = await appLinks.getInitialAppLink();
      print('Initial deep link captured in main(): $initialDeepLink');
    } catch (e) {
      print('Error getting initial deep link in main(): $e');
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn && token != null));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initDeepLinks();
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial URI if app was opened from a link
    try {
      // Check the global variable first (in case link opened the app)
      if (initialDeepLink != null) {
        print('Handling initial deep link from global variable: $initialDeepLink');
        _handleDeepLink(initialDeepLink!);
      }
    } catch (e) {
      print('Error handling initial deep link from global: $e');
    }

    // Listen for incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('Received URI from stream: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Error handling deep link: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    print('============ DEEP LINK RECEIVED ============');
    print('Received deep link: $uri');
    print('URI scheme: ${uri.scheme}');
    print('URI host: ${uri.host}');
    print('URI path: ${uri.path}');
    print('URI query parameters: ${uri.queryParameters}');
    print('Platform: ${Platform.operatingSystem}');
    print('============================================');

    // Accept any path as long as email and code parameters are present
    if (uri.queryParameters.containsKey('email') && 
        uri.queryParameters.containsKey('code')) {
      final email = uri.queryParameters['email']!;
      final code = uri.queryParameters['code']!;
      print('Navigating to change password screen with email: $email and code: $code');

      // Use a small delay to ensure the app is fully initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => NewPasswordScreen(email: email, code: code),
            ),
            (route) => false,
          );
          print('Successfully navigated to NewPasswordScreen');
        } catch (e) {
          print('Error navigating to NewPasswordScreen: $e');
          // As a fallback, try using a named route
          try {
            navigatorKey.currentState?.pushReplacementNamed('/changepass');
            print('Fallback: Navigated to /changepass route');
          } catch (e) {
            print('Error with fallback navigation: $e');
          }
        }
      });
    } else {
      print('Email or code parameter missing in URI: $uri');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
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
      initialRoute: widget.isLoggedIn ? AppRoutes.newMap : AppRoutes.welcome,
      routes: AppRoutes.getRoutes(),
    );
  }
}
