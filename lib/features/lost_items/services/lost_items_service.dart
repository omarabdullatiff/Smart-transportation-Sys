import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/lost_items.dart';

class LostItemsService {
  static Future<List<LostItem>> getAllLostItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/LostItems'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LostItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
} 