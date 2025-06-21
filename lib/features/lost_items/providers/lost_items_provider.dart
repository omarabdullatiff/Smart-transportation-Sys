import 'package:flutter_riverpod/flutter_riverpod.dart';

// Lost items providers placeholder - will be implemented later
final lostItemsListProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

final foundItemsListProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

final lostItemsLoadingProvider = StateProvider<bool>((ref) => false); 