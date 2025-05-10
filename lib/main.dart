import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/features/auth/screens/change_password_screen.dart';
import 'package:flutter_application_1/core/routes/app_routes.dart';
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
      initialRoute: widget.isLoggedIn ? AppRoutes.newMap : AppRoutes.welcome,
      routes: AppRoutes.getRoutes(),
    );
  }
}
