import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/lost_items.dart';

class LostItemsService {
  static const String baseUrl = 'http://smarttrackingapp.runasp.net/api/LostItems';
  static const String addLostItemUrl = 'http://smarttrackingapp.runasp.net/api/LostItems/add-lost-item';

  static Future<bool> reportLostItem(LostItem item, {File? imageFile}) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(addLostItemUrl));
      
      // Add headers
      request.headers.addAll({
        'accept': '*/*',
      });

      // Add form fields
      request.fields['BusNumber'] = item.busNumber;
      request.fields['Description'] = item.description;
      request.fields['ContactName'] = item.contactName;
      request.fields['ContactPhone'] = item.contactPhone;
      request.fields['PhotoUrl'] = item.photoUrl ?? 'https://via.placeholder.com/150';
      request.fields['ReportedAt'] = item.dateLost.toIso8601String();

      // Add photo file if provided
      if (imageFile != null) {
        try {
          var photoFile = await http.MultipartFile.fromPath(
            'photo',
            imageFile.path,
            filename: 'lost_item_photo.jpg',
          );
          request.files.add(photoFile);
          debugPrint('Photo file added: ${imageFile.path}');
        } catch (e) {
          debugPrint('Error adding photo file: $e');
          // Continue without photo if file handling fails
        }
      }

      debugPrint('Sending multipart request to: $addLostItemUrl');
      debugPrint('Form fields: ${request.fields}');
      debugPrint('Files count: ${request.files.length}');

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Lost item reported successfully');
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