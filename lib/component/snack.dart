import 'package:flutter/material.dart';

class SnackBarHelper {
  static void show(
      BuildContext context,
      String message, {
        Color backgroundColor = Colors.grey,
      }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
      elevation: 6,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
