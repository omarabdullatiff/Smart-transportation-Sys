import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/driver_model.dart';
import '../services/admin_api_service.dart';

// AsyncNotifier for drivers list with refresh capability
class DriversNotifier extends AsyncNotifier<List<Driver>> {
  @override
  Future<List<Driver>> build() async {
    return await AdminApiService.getAllDrivers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => AdminApiService.getAllDrivers());
  }

  Future<Driver> addDriver({
    required String name,
    required String phoneNumber,
    required String licenseNumber,
  }) async {
    try {
      // Create the driver via API
      final newDriver = await AdminApiService.createDriver(
        name: name,
        phoneNumber: phoneNumber,
        licenseNumber: licenseNumber,
      );
      
      // Refresh the list to include the new driver
      await refresh();
      
      return newDriver;
    } catch (e) {
      // If there's an error, re-throw it so the UI can handle it
      throw Exception('Failed to add driver: $e');
    }
  }

  Future<Driver> updateDriver({
    required int id,
    required String name,
    required String phoneNumber,
    required String licenseNumber,
  }) async {
    try {
      // Update the driver via API
      final updatedDriver = await AdminApiService.updateDriver(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
        licenseNumber: licenseNumber,
      );
      
      // Force refresh the list to show the updated driver data
      // This ensures the UI reflects the changes immediately
      state = const AsyncLoading();
      try {
        final updatedDrivers = await AdminApiService.getAllDrivers();
        state = AsyncData(updatedDrivers);
      } catch (e) {
        // If refresh fails, still return the updated driver but set error state
        state = AsyncError('Failed to refresh drivers list: $e', StackTrace.current);
      }
      
      return updatedDriver;
    } catch (e) {
      // If there's an error, re-throw it so the UI can handle it
      throw Exception('Failed to update driver: $e');
    }
  }

  Future<bool> deleteDriver(int id) async {
    try {
      // Delete the driver via API
      final success = await AdminApiService.deleteDriver(id);
      
      if (success) {
        // Force refresh the list to remove the deleted driver from UI
        // This ensures the UI reflects the changes immediately
        state = const AsyncLoading();
        try {
          final updatedDrivers = await AdminApiService.getAllDrivers();
          state = AsyncData(updatedDrivers);
        } catch (e) {
          // If refresh fails, set error state
          state = AsyncError('Failed to refresh drivers list: $e', StackTrace.current);
        }
      }
      
      return success;
    } catch (e) {
      // If there's an error, re-throw it so the UI can handle it
      throw Exception('Failed to delete driver: $e');
    }
  }
}

// Provider for the drivers list
final driversProvider = AsyncNotifierProvider<DriversNotifier, List<Driver>>(
  () => DriversNotifier(),
);

// Provider for driver statistics
final driverStatsProvider = Provider<Map<String, int>>((ref) {
  final driversAsync = ref.watch(driversProvider);
  
  return driversAsync.when(
    data: (drivers) {
      final stats = <String, int>{
        'available': 0,
        'driving': 0,
        'offline': 0,
      };
      
      for (final driver in drivers) {
        switch (driver.driverStatus) {
          case DriverStatus.available:
            stats['available'] = stats['available']! + 1;
            break;
          case DriverStatus.driving:
            stats['driving'] = stats['driving']! + 1;
            break;
          case DriverStatus.offline:
            stats['offline'] = stats['offline']! + 1;
            break;
        }
      }
      
      return stats;
    },
    loading: () => {
      'available': 0,
      'driving': 0,
      'offline': 0,
    },
    error: (_, __) => {
      'available': 0,
      'driving': 0,
      'offline': 0,
    },
  );
});

// Provider for a specific driver by ID
final driverByIdProvider = FutureProvider.family<Driver, int>((ref, id) async {
  return await AdminApiService.getDriverById(id);
});

// Provider for driver location by ID
final driverLocationProvider = FutureProvider.family<DriverLocation, int>((ref, driverId) async {
  return await AdminApiService.getDriverLocation(driverId);
}); 