import 'package:flutter/material.dart';

Widget buildIconButton(IconData icon, String label) {
  return Container(
    margin: EdgeInsets.zero, // Remove margin
    padding: EdgeInsets.zero, // Remove padding
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: 18, vertical: 10), // Adjust padding
      ),
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ensure the row takes minimum space
        children: [
          Icon(icon, size: 26, color: Colors.grey[800]),
          SizedBox(width: 5), // Space between icon and text
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildBottomButton(String label, Color color) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    onPressed: () {},
    child: Padding(
      padding: EdgeInsets.all(15),
      child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
    ),
  );
}
