import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/features/admin/providers/buses_provider.dart';
import 'package:flutter_application_1/features/admin/models/bus_model.dart';
import 'package:flutter_application_1/features/admin/widgets/admin_widgets.dart';
import 'package:flutter_application_1/features/admin/widgets/bus_dialogs.dart';

class BusManagementWidget extends ConsumerWidget {
  const BusManagementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(ref),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildBusesSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildStatsCards(WidgetRef ref) {
    final busStats = ref.watch(busStatsProvider);
    
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Active Buses',
            value: '${busStats['active']}',
            icon: Icons.directions_bus,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Out of Service',
            value: '${busStats['outOfService']}',
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Maintenance',
            value: '${busStats['maintenance']}',
            icon: Icons.build,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
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
                title: 'Create Bus',
                icon: Icons.add_circle,
                color: AppColor.primary,
                onTap: () => BusDialogs.showCreateBusDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBusesSection(BuildContext context, WidgetRef ref) {
    final busesAsync = ref.watch(busesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'All Buses',
          action: CustomButton(
            text: 'Refresh',
            type: ButtonType.text,
            icon: Icons.refresh,
            onPressed: () {
              ref.read(busesProvider.notifier).refresh();
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400, // Fixed height to allow scrolling
          child: busesAsync.when(
            data: (buses) {
              if (buses.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No buses found',
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
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  return BusCard(bus: buses[index]);
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
                      'Error loading buses',
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
                        ref.read(busesProvider.notifier).refresh();
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

class BusCard extends ConsumerWidget {
  final Bus bus;

  const BusCard({super.key, required this.bus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InfoCard(
      title: '${bus.licensePlate} - ${bus.model}',
      subtitle: '${bus.route} • Capacity: ${bus.capacity} passengers',
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.directions_bus,
          color: AppColor.primary,
          size: 24,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: bus.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bus.status,
                style: TextStyle(
                  color: bus.statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => BusDialogs.handleBusAction(context, ref, value, bus),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Edit Bus',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.toggle_on, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Change Status',
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
                    Icon(Icons.person_add, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Assign Driver',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'assignTrip',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Assign to Trip',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unassignTrip',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route_outlined, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Unassign from Trip',
                        style: TextStyle(color: Colors.orange),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unassign',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_remove, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Unassign Driver',
                        style: TextStyle(color: Colors.orange),
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
