import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/lost_items.dart';

class LostItemsService {
  static const String baseUrl = 'http://smarttrackingapp.runasp.net/api/LostItems';

  static Future<bool> reportLostItem(LostItem item, {File? imageFile}) async {
    try {
      String photoUrl = 'https://via.placeholder.com/150'; // Default placeholder
      
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        photoUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final lostItem = LostItem(
        description: item.description,
        dateLost: item.dateLost,
        busNumber: item.busNumber,
        contactName: item.contactName,
        contactPhone: item.contactPhone,
        photoUrl: photoUrl,
      );

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(lostItem.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to report lost item. Status Code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error reporting lost item: $e');
      return false;
    }
  }

  static Future<List<LostItem>> getAllLostItems() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'accept': '*/*',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LostItem.fromJson(json)).toList();
      }
      debugPrint('Failed to get lost items. Status Code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Error fetching lost items: $e');
      return [];
    }
  }
} 