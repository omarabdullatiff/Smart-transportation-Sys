import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_color.dart';

class FoundItemsScreen extends StatelessWidget {
  FoundItemsScreen({super.key});

  final List<Map<String, String>> items = [
    {
      "image": "lib/image/image1.jpeg",
      "title": "Red  Bag",
      "date": "Jan 10, 2024",
      "id": "101",
    },
    {
      "image": "lib/image/image1.jpeg",
      "title": "Blue Backpack",
      "date": "Mar 12, 2024",
      "id": "103",
    },
    {
      "image": "lib/image/image2.jpeg",
      "title": "School Blue Backpack",
      "date": "Apr 14, 2024",
      "id": "107",
    },
    {
      "image": "lib/image/image3.jpeg",
      "title": "Brown Leather Bag",
      "date": "Feb 16, 2024",
      "id": "100",
    },
    {
      "image": "lib/image/image4.jpeg",
      "title": "Red Leather Bag",
      "date": "May 18, 2024",
      "id": "105",
    },
    {
      "image": "lib/image/image5.jpeg",
      "title": "Olive Handbag",
      "date": "Apr 20, 2024",
      "id": "106",
    },
    {
      "image": "lib/image/image6.jpeg",
      "title": "Black Bag",
      "date": "Jan 22, 2024",
      "id": "109",
    },
    {
      "image": "lib/image/image7.jpeg",
      "title": "Brown Leather Bag",
      "date": "Feb 24, 2024",
      "id": "115",
    },
    {
      "image": "lib/image/image8.jpeg",
      "title": "Blue Leather Bag",
      "date": "May 26, 2024",
      "id": "105",
    },
    {
      "image": "lib/image/image9.jpeg",
      "title": "Black Bag Backpack",
      "date": "Mar 15, 2024",
      "id": "109",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color:AppColor.primaryDark),
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
                child: GridView.builder(
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
                        color: Colors.white, // White background
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
                                child: Image.asset(
                                  item["image"]!,
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
                                  item["title"]!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item["date"]!,
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
                                          item["id"]!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Colors.lightGreen.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
