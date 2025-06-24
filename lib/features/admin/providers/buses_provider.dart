import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bus_model.dart';
import '../services/admin_api_service.dart';

// AsyncNotifier for buses list with refresh capability
class BusesNotifier extends AsyncNotifier<List<Bus>> {
  @override
  Future<List<Bus>> build() async {
    return await AdminApiService.getAllBuses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => AdminApiService.getAllBuses());
  }

  Future<bool> changeBusStatus(int busId, int status) async {
    try {
      // Change the bus status via API
      final success = await AdminApiService.changeBusStatus(busId, status);
      
      if (success) {
        // Force refresh the list to show the updated bus status
        // This ensures the UI reflects the changes immediately
        state = const AsyncLoading();
        try {
          final updatedBuses = await AdminApiService.getAllBuses();
          state = AsyncData(updatedBuses);
        } catch (e) {
          // If refresh fails, set error state
          state = AsyncError('Failed to refresh buses list: $e', StackTrace.current);
        }
      }
      
      return success;
    } catch (e) {
      // If there's an error, re-throw it so the UI can handle it
      throw Exception('Failed to change bus status: $e');
    }
  }

  Future<bool> assignDriverToBus(int busId, int driverId) async {
    try {
      // Assign the driver to bus via API
      final success = await AdminApiService.assignDriverToBus(busId, driverId);
      
      if (success) {
        // Force refresh the list to show the updated bus assignments
        // This ensures the UI reflects the changes immediately
        state = const AsyncLoading();
        try {
          final updatedBuses = await AdminApiService.getAllBuses();
          state = AsyncData(updatedBuses);
        } catch (e) {
          // If refresh fails, set error state
          state = AsyncError('Failed to refresh buses list: $e', StackTrace.current);
        }
      }
      
      return success;
    } catch (e) {
      // If there's an error, re-throw it so the UI can handle it
      throw Exception('Failed to assign driver to bus: $e');
    }
  }

  Future<bool> deleteBus(int busId) async {
    try {
      // Delete the bus via API
      final success = await AdminApiService.deleteBus(busId);
      
      if (success) {
        // Force refresh the list to remove the deleted bus from UI
        // This ensures the UI reflects the changes immediately
        state = const AsyncLoading();
        try {
          final updatedBuses = await AdminApiService.getAllBuses();
          state = AsyncData(updatedBuses);
        } catch (e) {
          // If refresh fails, set error state
          state = AsyncError('Failed to refresh buses list: $e', StackTrace.current);
        }
      }
      
      return success;
    } catch (e) {
      // If there's an error, re-throw it so the UI can handle it
      throw Exception('Failed to delete bus: $e');
    }
  }
}

// Provider for the buses list
final busesProvider = AsyncNotifierProvider<BusesNotifier, List<Bus>>(
  () => BusesNotifier(),
);

// Provider for bus statistics
final busStatsProvider = Provider<Map<String, int>>((ref) {
  final busesAsync = ref.watch(busesProvider);
  
  return busesAsync.when(
    data: (buses) {
      final stats = <String, int>{
        'active': 0,
        'inactive': 0,
        'maintenance': 0,
        'outOfService': 0,
      };
      
      for (final bus in buses) {
        switch (bus.busStatus) {
          case BusStatus.active:
            stats['active'] = stats['active']! + 1;
            break;
          case BusStatus.inactive:
            stats['inactive'] = stats['inactive']! + 1;
            break;
          case BusStatus.maintenance:
            stats['maintenance'] = stats['maintenance']! + 1;
            break;
          case BusStatus.outOfService:
            stats['outOfService'] = stats['outOfService']! + 1;
            break;
        }
      }
      
      return stats;
    },
    loading: () => {
      'active': 0,
      'inactive': 0,
      'maintenance': 0,
      'outOfService': 0,
    },
    error: (_, __) => {
      'active': 0,
      'inactive': 0,
      'maintenance': 0,
      'outOfService': 0,
    },
  );
}); 