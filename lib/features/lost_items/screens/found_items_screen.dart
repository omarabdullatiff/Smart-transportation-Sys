import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/lost_items_service.dart';
import '../models/lost_items.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class FoundItemsScreen extends StatefulWidget {
  const FoundItemsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FoundItemsScreenState createState() => _FoundItemsScreenState();
}

class _FoundItemsScreenState extends State<FoundItemsScreen> {
  late Future<List<LostItem>> _foundItemsFuture;

  @override
  void initState() {
    super.initState();
    _foundItemsFuture = LostItemsService.getAllLostItems(); // Load data from API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Found Items",
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Search for misplaced items",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<LostItem>>(
                  future: _foundItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading items'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No items found'));
                    }

                    final items = snapshot.data!;

                    return GridView.builder(
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: item.photoUrl == null
                                      ? Image.network(
                                          'https://via.placeholder.com/150',
                                          width: double.infinity,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : item.photoUrl!.startsWith('data:image')
                                        ? Image.memory(
                                            base64Decode(item.photoUrl!.split(',')[1]),
                                            width: double.infinity,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            item.photoUrl!,
                                            width: double.infinity,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "Found",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.dateLost.toLocal().toString().split(".")[0],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.directions_bus,
                                              size: 16,
                                              color: Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.busNumber,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Contact Information'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Name: ${item.contactName}'),
                                                      SizedBox(height: 8),
                                                      Text('Phone: ${item.contactPhone}'),
                                                      SizedBox(height: 16),
                                                      if (Platform.isAndroid || Platform.isIOS)
                                                        Text(
                                                          'Note: In emulator, phone calls are simulated.',
                                                          style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: Text('Close'),
                                                    ),
                                                    ElevatedButton.icon(
                                                      onPressed: () async {
                                                        final Uri phoneUri = Uri(
                                                          scheme: 'tel',
                                                          path: item.contactPhone,
                                                        );
                                                        
                                                        try {
                                                          if (await canLaunchUrl(phoneUri)) {
                                                            await launchUrl(phoneUri);
                                                            if (context.mounted) {
                                                              Navigator.pop(context);
                                                            }
                                                          } else {
                                                            if (context.mounted) {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) => AlertDialog(
                                                                  title: Text('Phone Call Simulation'),
                                                                  content: Text(
                                                                    'In the emulator, this would open the phone app to call:\n\n${item.contactPhone}\n\nOn a real device, this would initiate a phone call.',
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context); // Close simulation dialog
                                                                        Navigator.pop(context); // Close contact dialog
                                                                      },
                                                                      child: Text('OK'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        } catch (e) {
                                                          if (context.mounted) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: Text('Phone Call Simulation'),
                                                                content: Text(
                                                                  'In the emulator, this would open the phone app to call:\n\n${item.contactPhone}\n\nOn a real device, this would initiate a phone call.',
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(context); // Close simulation dialog
                                                                      Navigator.pop(context); // Close contact dialog
                                                                    },
                                                                    child: Text('OK'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      icon: Icon(Icons.phone, color: Colors.white),
                                                      label: Text('Call'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen.shade700,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 10,
                                            ),
                                            minimumSize: const Size(0, 24),
                                          ),
                                          child: const Text(
                                            "Contact",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
