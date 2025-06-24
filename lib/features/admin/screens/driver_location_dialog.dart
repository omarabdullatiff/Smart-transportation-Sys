import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/features/admin/models/driver_model.dart';
import 'package:flutter_application_1/features/admin/providers/drivers_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverLocationDialog extends ConsumerWidget {
  final Driver driver;

  const DriverLocationDialog({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(driverLocationProvider(driver.id));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.my_location,
                    color: AppColor.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${driver.name} Location',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'License: ${driver.licenseNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            locationAsync.when(
              data: (location) => _buildLocationInfo(context, location),
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading location...'),
                  ],
                ),
              ),
              error: (error, stackTrace) => _buildErrorInfo(context, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context, DriverLocation location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColor.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLocationRow('Latitude', location.latitude.toString()),
              const SizedBox(height: 8),
              _buildLocationRow('Longitude', location.longitude.toString()),
              if (location.timestamp != null) ...[
                const SizedBox(height: 8),
                _buildLocationRow(
                  'Last Updated',
                  _formatTimestamp(location.timestamp!),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Open in Maps',
                type: ButtonType.primary,
                icon: Icons.map,
                onPressed: () => _openInMaps(location),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Refresh',
                type: ButtonType.outline,
                icon: Icons.refresh,
                onPressed: () => _refreshLocation(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorInfo(BuildContext context, String error) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Failed to load location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Retry',
          type: ButtonType.primary,
          onPressed: () => _refreshLocation(context),
        ),
      ],
    );
  }

  void _refreshLocation(BuildContext context) {
    // This will trigger a refresh of the location provider
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => DriverLocationDialog(driver: driver),
    );
  }

  Future<void> _openInMaps(DriverLocation location) async {
    final url = 'https://www.google.com/maps?q=${location.latitude},${location.longitude}';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
} 