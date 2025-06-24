import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/features/admin/models/driver_model.dart';
import 'package:flutter_application_1/features/admin/models/bus_model.dart';
import 'package:flutter_application_1/features/admin/providers/drivers_provider.dart';
import 'package:flutter_application_1/features/admin/providers/buses_provider.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';

class DriverSelectionDialog extends ConsumerWidget {
  final Bus bus;

  const DriverSelectionDialog({
    super.key,
    required this.bus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(driversProvider);

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
                    Icons.person_add,
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
                        'Assign Driver to ${bus.licensePlate}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${bus.model} • ${bus.route}',
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
            SizedBox(
              height: 400,
              width: double.maxFinite,
              child: driversAsync.when(
                data: (drivers) => _buildDriversList(context, ref, drivers),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading drivers...'),
                    ],
                  ),
                ),
                error: (error, stackTrace) => _buildErrorState(context, ref, error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversList(BuildContext context, WidgetRef ref, List<Driver> drivers) {
    if (drivers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No drivers available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a driver:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return _buildDriverCard(context, ref, driver);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(BuildContext context, WidgetRef ref, Driver driver) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: driver.statusColor.withValues(alpha: 0.1),
          child: Text(
            driver.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(),
            style: TextStyle(
              color: driver.statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          driver.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          driver.statusText,
          style: TextStyle(
            color: driver.statusColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: CustomButton(
          text: 'Assign',
          type: ButtonType.primary,
          onPressed: () => _assignDriver(context, ref, driver),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load drivers',
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
            onPressed: () {
              ref.read(driversProvider.notifier).refresh();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _assignDriver(BuildContext context, WidgetRef ref, Driver driver) async {
    try {
      // Show loading message
      CustomSnackBar.showInfo(
        context: context,
        message: 'Assigning ${driver.name} to ${bus.licensePlate}...',
      );

      // Call the API to assign driver to bus
      final success = await ref.read(busesProvider.notifier).assignDriverToBus(
        bus.id,
        driver.id,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop(); // Close the dialog
        CustomSnackBar.showSuccess(
          context: context,
          message: '${driver.name} assigned to ${bus.licensePlate} successfully! Refreshing list...',
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Failed to assign ${driver.name} to ${bus.licensePlate}: ${e.toString()}',
        );
      }
    }
  }
} 