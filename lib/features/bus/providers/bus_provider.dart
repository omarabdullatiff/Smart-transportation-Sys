import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bus providers placeholder - will be implemented later
final busListProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

final selectedBusProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final busLoadingProvider = StateProvider<bool>((ref) => false); 