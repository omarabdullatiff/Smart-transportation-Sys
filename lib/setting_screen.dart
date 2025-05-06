import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_color.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColor.primaryLight,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          _buildSettingsItem('My Account', Icons.person_outline, () {
            Navigator.pushNamed(context, '/profile');
          }),
          _buildSettingsItem('Notification', Icons.notifications_none, () {
            Navigator.pushNamed(context, '/notifications');
          }),
          _buildSettingsItem('Privacy Settings', Icons.lock_outline, () {
            Navigator.pushNamed(context, '/privacy');
          }),

          const SizedBox(height: 24),
          _buildSectionHeader('More'),
          _buildSettingsItem('About this app', Icons.info_outline, () {
            Navigator.pushNamed(context, '/about');
          }),
          _buildSettingsItem('Terms & Conditions', Icons.description_outlined, () {
            Navigator.pushNamed(context, '/terms');
          }),
          _buildSettingsItem('Help Center', Icons.help_outline, () {
            Navigator.pushNamed(context, '/help');
          }),
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

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
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
      onTap: onTap,
    );
  }
}
