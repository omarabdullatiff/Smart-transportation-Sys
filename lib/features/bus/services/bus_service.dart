import 'dart:convert';
import 'package:http/http.dart' as http;

class BusService {
  static Future<List<Map<String, dynamic>>> fetchAllBuses() async {
    final response = await http.get(
      Uri.parse('http://smarttrackingapp.runasp.net/api/Bus/Buses'),
      headers: {'accept': 'application/json'},
    );
    print('API response: ${response.body}');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final buses = data.map<Map<String, dynamic>>((bus) => {
        'number': bus['id']?.toString() ?? '',
        'org': bus['origin']?.toString() ?? '',
        'dest': bus['destination']?.toString() ?? '',
      }).toList();
      return buses;
    } else {
      throw Exception('Failed to load buses');
    }
  }
} 