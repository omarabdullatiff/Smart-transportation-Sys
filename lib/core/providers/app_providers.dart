import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Theme provider
final themeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

// Loading state provider (global loading indicator)
final globalLoadingProvider = StateProvider<bool>((ref) => false);

// Network connectivity provider
final connectivityProvider = StateProvider<bool>((ref) => true);

// Current location provider
final currentLocationProvider = StateProvider<Map<String, double>?>((ref) => null);

// App initialization provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Initialize app dependencies
  final prefs = ref.read(sharedPreferencesProvider);
  
  // Check if user is logged in
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  // Initialize other app state if needed
  
  return true;
}); 