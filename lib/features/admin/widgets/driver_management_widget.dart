import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/features/admin/providers/drivers_provider.dart';
import 'package:flutter_application_1/features/admin/models/driver_model.dart';
import 'package:flutter_application_1/features/admin/widgets/admin_widgets.dart';
import 'package:flutter_application_1/features/admin/widgets/driver_dialogs.dart';

class DriverManagementWidget extends ConsumerWidget {
  const DriverManagementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(driversProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDriverStats(ref),
            const SizedBox(height: 24),
            _buildDriverActions(context),
            const SizedBox(height: 24),
            _buildDriversList(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStats(WidgetRef ref) {
    final driverStats = ref.watch(driverStatsProvider);
    
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Available',
            value: '${driverStats['available']}',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Driving',
            value: '${driverStats['driving']}',
            icon: Icons.drive_eta,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Offline',
            value: '${driverStats['offline']}',
            icon: Icons.offline_bolt,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driver Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'Add Driver',
                icon: Icons.person_add,
                color: AppColor.primary,
                onTap: () => DriverDialogs.showAddDriverDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriversList(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(driversProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'All Drivers',
          action: CustomButton(
            text: 'Refresh',
            type: ButtonType.text,
            icon: Icons.refresh,
            onPressed: () {
              ref.read(driversProvider.notifier).refresh();
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400, // Fixed height to allow scrolling
          child: driversAsync.when(
            data: (drivers) {
              if (drivers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
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
                          'No drivers found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  return DriverCard(driver: drivers[index]);
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading drivers',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DriverCard extends ConsumerWidget {
  final Driver driver;

  const DriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InfoCard(
      title: driver.name,
      subtitle: 'License: ${driver.licenseNumber} • Phone: ${driver.phoneNumber}',
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppColor.primary.withValues(alpha: 0.1),
        child: Text(
          driver.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(),
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: driver.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                driver.statusText,
                style: TextStyle(
                  color: driver.statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => DriverDialogs.handleDriverAction(context, ref, value, driver),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'update',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Update Driver',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'assign',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Assign Trip',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'track',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Track Location',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
