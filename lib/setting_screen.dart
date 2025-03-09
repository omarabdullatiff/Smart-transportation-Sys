import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_color.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings'
          ,style: TextStyle(
            color: AppColor.primaryLight,
          ),
          ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          _buildSettingsItem('My Account', Icons.person_outline),
          _buildSettingsItem('Notification', Icons.notifications_none),
          _buildSettingsItem('Privacy Settings', Icons.lock_outline),
          
          const SizedBox(height: 24),
          _buildSectionHeader('More'),
          _buildSettingsItem('About this app', Icons.info_outline),
          _buildSettingsItem('Terms & Conditions', Icons.description_outlined),
          _buildSettingsItem('Help Center', Icons.help_outline),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Add navigation logic for each item
      },
    );
  }
}