import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver_model.dart';
import '../models/bus_model.dart';

class AdminApiService {
  static const String _baseUrl = 'http://smarttrackingapp.runasp.net/api';
  
  static Future<List<Driver>> getAllDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/AdminDriver'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Driver.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching drivers: $e');
    }
  }

  static Future<List<Bus>> getAllBuses() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Busv2/Bus'),
        headers: {
          'accept': 'text/plain',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Bus.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load buses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching buses: $e');
    }
  }

  static Future<Driver> getDriverById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/AdminDriver/$id'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Driver.fromJson(json);
      } else {
        throw Exception('Failed to load driver: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching driver: $e');
    }
  }

  static Future<DriverLocation> getDriverLocation(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/AdminDriver/$driverId/location'),
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return DriverLocation.fromJson(json);
      } else {
        throw Exception('Failed to load driver location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching driver location: $e');
    }
  }

  static Future<Driver> createDriver({
    required String name,
    required String phoneNumber,
    required String licenseNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/AdminDriver'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'phoneNumber': phoneNumber,
          'licenseNumber': licenseNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Driver.fromJson(json);
      } else {
        throw Exception('Failed to create driver: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating driver: $e');
    }
  }

  static Future<Driver> updateDriver({
    required int id,
    required String name,
    required String phoneNumber,
    required String licenseNumber,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/AdminDriver/$id'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'phoneNumber': phoneNumber,
          'licenseNumber': licenseNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // For 204 No Content, we need to fetch the updated driver separately
        // or return a driver object with the updated data
        if (response.statusCode == 204 || response.body.isEmpty) {
          // Return updated driver object with the new data
          // We'll use a default status of 0 (available) since it's not provided
          return Driver(
            id: id,
            name: name,
            phoneNumber: phoneNumber,
            licenseNumber: licenseNumber,
            status: 0, // Default to available status
          );
        } else {
          // For 200 with response body
          final Map<String, dynamic> json = jsonDecode(response.body);
          return Driver.fromJson(json);
        }
      } else {
        throw Exception('Failed to update driver: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating driver: $e');
    }
  }

  static Future<bool> deleteDriver(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/AdminDriver/$id'),
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Successfully deleted
      } else if (response.statusCode == 500) {
        // Handle server error - likely due to foreign key constraint (driver assigned to trip)
        throw Exception('DRIVER_HAS_TRIPS');
      } else if (response.statusCode == 404) {
        // Driver not found
        throw Exception('DRIVER_NOT_FOUND');
      } else if (response.statusCode == 400) {
        // Bad request
        throw Exception('INVALID_REQUEST');
      } else {
        throw Exception('DELETE_FAILED_${response.statusCode}');
      }
    } catch (e) {
      // Re-throw custom exceptions as-is, wrap others
      if (e.toString().contains('DRIVER_HAS_TRIPS') ||
          e.toString().contains('DRIVER_NOT_FOUND') ||
          e.toString().contains('INVALID_REQUEST') ||
          e.toString().contains('DELETE_FAILED_')) {
        rethrow;
      }
      throw Exception('NETWORK_ERROR: $e');
    }
  }

  static Future<bool> changeBusStatus(int busId, int status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/AdminTrip/$busId/status'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Successfully updated
      } else {
        throw Exception('Failed to change bus status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error changing bus status: $e');
    }
  }

  static Future<bool> assignDriverToBus(int busId, int driverId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/AdminTrip/$busId/assign-driver/$driverId'),
        headers: {
          'accept': '*/*',
        },
        body: '',
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return true; // Successfully assigned
      } else {
        throw Exception('Failed to assign driver to bus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error assigning driver to bus: $e');
    }
  }

  static Future<bool> deleteBus(int busId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/AdminTrip/$busId/unassign-driver'),
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Successfully deleted
      } else {
        throw Exception('Failed to delete bus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting bus: $e');
    }
  }

  static Future<Bus> createBus({
    required String model,
    required int capacity,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/AdminBus'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': 0,
          'licensePlate': 'AUTO-${DateTime.now().millisecondsSinceEpoch}', // Auto-generated license plate
          'model': model,
          'capacity': capacity,
          'status': status,
          'origin': 'To be assigned', // Default value
          'destination': 'To be assigned', // Default value
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Bus.fromJson(json);
      } else {
        throw Exception('Failed to create bus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating bus: $e');
    }
  }
} 