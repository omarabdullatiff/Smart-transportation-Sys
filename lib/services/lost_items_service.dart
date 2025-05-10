import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lost_items.dart';

class LostItemsService {
  static const String baseUrl = 'http://smarttrackingapp.runasp.net/api/LostItems';

  // POST: Report a lost item
  static Future<bool> reportLostItem(LostItem item) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // ignore: avoid_print
        print('Failed to report lost item. Status Code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error reporting lost item: $e');
      return false;
    }
  }

  // GET: Get all lost items
  static Future<List<LostItem>> getLostItems() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LostItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lost items');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching lost items: $e');
      return []; // Return empty list on error
    }
  }

  // GET: Get a single lost item by ID
  static Future<LostItem?> getLostItemById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LostItem.fromJson(data);
      } else {
        throw Exception('Failed to load lost item');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching lost item by ID: $e');
      return null;
    }
  }

  // DELETE: Delete a lost item by ID
  static Future<bool> deleteLostItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting lost item: $e');
      return false;
    }
  }

  // GET: Get all lost items (wrapper function)
  static Future<List<LostItem>> getAllLostItems() async {
    try {
      return await getLostItems(); // إعادة استخدام الدالة getLostItems
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching all lost items: $e');
      return []; // Return empty list on error
    }
  }
}
