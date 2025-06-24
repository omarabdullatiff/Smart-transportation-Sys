import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_text_field.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/shared/widgets/custom_card.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';
import 'package:flutter_application_1/features/admin/providers/drivers_provider.dart';
import 'package:flutter_application_1/features/admin/providers/buses_provider.dart';
import 'package:flutter_application_1/features/admin/models/driver_model.dart';
import 'package:flutter_application_1/features/admin/models/bus_model.dart';
import 'package:flutter_application_1/features/admin/screens/driver_location_dialog.dart';
import 'package:flutter_application_1/features/admin/screens/driver_selection_dialog.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await CustomDialog.showConfirmation(
                context: context,
                title: 'Logout',
                message: 'Are you sure you want to logout?',
                confirmText: 'Logout',
                confirmType: ButtonType.danger,
                icon: Icons.logout,
              );
              
              if (confirmed == true && mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.route),
              text: 'Trip Management',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Driver Management',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTripManagement(),
          _buildDriverManagement(),
        ],
      ),
    );
  }

  Widget _buildTripManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildTripsSection(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
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

  Widget _buildQuickActions() {
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
                title: 'Create Trip',
                icon: Icons.add_circle,
                color: AppColor.primary,
                onTap: () => _showCreateTripDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripsSection() {
    final busesAsync = ref.watch(busesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Buses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            CustomButton(
              text: 'Refresh',
              type: ButtonType.text,
              icon: Icons.refresh,
              onPressed: () {
                ref.read(busesProvider.notifier).refresh();
              },
            ),
          ],
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
                // Scrollable list of buses
                itemCount: buses.length,
          itemBuilder: (context, index) {
                  return _buildBusCard(buses[index]);
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

  Widget _buildBusCard(Bus bus) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bus.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bus.status,
              style: TextStyle(
                color: bus.statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleBusAction(value, bus),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Bus'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    Icon(Icons.toggle_on, size: 18),
                    SizedBox(width: 8),
                    Text('Change Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'assign',
                child: Row(
                  children: [
                    Icon(Icons.person_add, size: 18),
                    SizedBox(width: 8),
                    Text('Assign Driver'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleBusAction(String action, Bus bus) {
    switch (action) {
      case 'edit':
        CustomSnackBar.showInfo(
          context: context,
          message: 'Edit bus ${bus.licensePlate} functionality coming soon...',
        );
        break;
      case 'status':
        _showBusStatusDialog(bus);
        break;
      case 'assign':
        _showDriverSelectionDialog(bus);
        break;
      case 'delete':
        _showDeleteBusConfirmation(bus);
        break;
    }
  }

  void _showBusStatusDialog(Bus bus) {
    final items = [
      ListDialogItem(
        title: 'Active',
        value: 0, // API expects integer values
        icon: Icons.circle,
      ),
      ListDialogItem(
        title: 'Out of Service',
        value: 1,
        icon: Icons.circle,
      ),
      ListDialogItem(
        title: 'Maintenance',
        value: 2,
        icon: Icons.build,
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => ListDialog<int>(
        title: 'Change Status - ${bus.licensePlate}',
        items: items,
        onItemSelected: (statusValue) async {
          try {
            // Show loading message
            CustomSnackBar.showInfo(
              context: context,
              message: 'Updating ${bus.licensePlate} status...',
            );

            // Call the API to change bus status
            final success = await ref.read(busesProvider.notifier).changeBusStatus(
              bus.id,
              statusValue,
            );

            if (success && mounted) {
              final statusNames = {
                0: 'Active',
                1: 'Out of Service', 
                2: 'Maintenance',
              };
              
              CustomSnackBar.showSuccess(
                context: context,
                message: '${bus.licensePlate} status changed to ${statusNames[statusValue]}! Refreshing list...',
              );
            }
          } catch (e) {
            if (mounted) {
              CustomSnackBar.showError(
                context: context,
                message: 'Failed to change ${bus.licensePlate} status: ${e.toString()}',
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteBusConfirmation(Bus bus) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete bus ${bus.licensePlate}?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      confirmType: ButtonType.danger,
      icon: Icons.delete,
      iconColor: Colors.red,
    );

    if (confirmed == true && mounted) {
      try {
        // Show loading indicator
        CustomSnackBar.showInfo(
          context: context,
          message: 'Deleting bus ${bus.licensePlate}...',
        );

        // Call the API to delete the bus
        final success = await ref.read(busesProvider.notifier).deleteBus(bus.id);

        if (success && mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Bus ${bus.licensePlate} deleted successfully! Refreshing list...',
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(
            context: context,
            message: 'Failed to delete bus ${bus.licensePlate}: ${e.toString()}',
          );
        }
      }
    }
  }

  Widget _buildDriverManagement() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(driversProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDriverStats(),
          const SizedBox(height: 24),
          _buildDriverActions(),
          const SizedBox(height: 24),
          _buildDriversList(),
        ],
        ),
      ),
    );
  }

  Widget _buildDriverStats() {
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

  Widget _buildDriverActions() {
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
                onTap: () => _showAddDriverDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriversList() {
    final driversAsync = ref.watch(driversProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'All Drivers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
            ),
            CustomButton(
              text: 'Refresh',
              type: ButtonType.text,
              icon: Icons.refresh,
              onPressed: () {
                ref.read(driversProvider.notifier).refresh();
              },
            ),
          ],
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
                // Removed shrinkWrap and NeverScrollableScrollPhysics to allow scrolling
                itemCount: drivers.length,
          itemBuilder: (context, index) {
                  return _buildDriverCard(drivers[index]);
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

  Widget _buildDriverCard(Driver driver) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: driver.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              driver.statusText,
              style: TextStyle(
                color: driver.statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleDriverAction(value, driver),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Update Driver'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'assign',
                child: Row(
                  children: [
                    Icon(Icons.assignment, size: 18),
                    SizedBox(width: 8),
                    Text('Assign Trip'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'track',
                child: Row(
                  children: [
                    Icon(Icons.my_location, size: 18),
                    SizedBox(width: 8),
                    Text('Track Location'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateTripDialog() {
    final routeController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final recurrenceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => FormDialog(
        title: 'Create New Trip',
        fields: [
          CustomTextField(
            controller: routeController,
            label: 'Route Name',
            hint: 'Enter route name',
            prefixIcon: Icons.route,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: startController,
            label: 'Start Location',
            hint: 'Enter start location',
            prefixIcon: Icons.location_on,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: endController,
            label: 'End Location',
            hint: 'Enter end location',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: recurrenceController,
            label: 'Recurrence (minutes)',
            hint: 'Enter recurrence in minutes',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.schedule,
          ),
        ],
        onSave: () {
          Navigator.pop(context);
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Trip created successfully!',
          );
        },
      ),
    );
  }

  void _showAddDriverDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final licenseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return AlertDialog(
            title: const Text('Add New Driver'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
          CustomTextField(
            controller: nameController,
            label: 'Full Name',
            hint: 'Enter full name',
            prefixIcon: Icons.person,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: phoneController,
            label: 'Phone Number',
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: licenseController,
            label: 'License Number',
            hint: 'Enter license number',
            prefixIcon: Icons.credit_card,
            textCapitalization: TextCapitalization.characters,
          ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () {
          Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  // Validate input
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      licenseController.text.trim().isEmpty) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please fill in all fields',
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    // Call the API to create the driver
                    await ref.read(driversProvider.notifier).addDriver(
                      name: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      licenseNumber: licenseController.text.trim(),
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      CustomSnackBar.showSuccess(
          context: context,
                        message: 'Driver added successfully!',
                      );
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    
                    if (mounted) {
                      CustomSnackBar.showError(
      context: context,
                        message: 'Failed to add driver: ${e.toString()}',
                      );
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Add Driver'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleDriverAction(String action, Driver driver) {
    switch (action) {
      case 'update':
        _showUpdateDriverDialog(driver);
        break;
      case 'assign':
        _showAssignTripDialog(driver.name);
        break;
      case 'track':
        _showTrackLocationDialog(driver);
        break;
      case 'delete':
        _showDeleteDriverConfirmation(driver);
        break;
    }
  }

  void _showAssignTripDialog(String driverName) {
    final trips = List.generate(
      5,
      (index) => ListDialogItem(
        title: 'Trip ${index + 1}',
        subtitle: 'Available',
        value: index,
        icon: Icons.directions_bus,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => ListDialog<int>(
        title: 'Assign Trip - $driverName',
        items: trips,
        onItemSelected: (tripIndex) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Trip ${tripIndex + 1} assigned to $driverName',
          );
        },
      ),
    );
  }

  void _showDeleteDriverConfirmation(Driver driver) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete ${driver.name}?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      confirmType: ButtonType.danger,
      icon: Icons.delete,
      iconColor: Colors.red,
    );

    if (confirmed == true && mounted) {
      try {
        // Show loading indicator
        CustomSnackBar.showInfo(
          context: context,
          message: 'Deleting ${driver.name}...',
        );

        // Call the API to delete the driver
        final success = await ref.read(driversProvider.notifier).deleteDriver(driver.id);

        if (success && mounted) {
      CustomSnackBar.showSuccess(
        context: context,
            message: '${driver.name} deleted successfully! Refreshing list...',
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = _getDeleteErrorMessage(e.toString(), driver.name);
          
          if (e.toString().contains('DRIVER_HAS_TRIPS')) {
            // Show a more detailed dialog for this specific case
            _showDriverHasTripsDialog(driver);
          } else {
            CustomSnackBar.showError(
              context: context,
              message: errorMessage,
            );
          }
        }
      }
    }
  }

  String _getDeleteErrorMessage(String error, String driverName) {
    if (error.contains('DRIVER_HAS_TRIPS')) {
      return 'Cannot delete $driverName - driver is assigned to active trips';
    } else if (error.contains('DRIVER_NOT_FOUND')) {
      return 'Driver not found. They may have already been deleted.';
    } else if (error.contains('INVALID_REQUEST')) {
      return 'Invalid request. Please try again.';
    } else if (error.contains('NETWORK_ERROR')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.contains('DELETE_FAILED_')) {
      return 'Failed to delete driver. Server error occurred.';
    } else {
      return 'Failed to delete $driverName: ${error.toString()}';
    }
  }

  void _showDriverHasTripsDialog(Driver driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cannot Delete Driver',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${driver.name} cannot be deleted because they are currently assigned to one or more active trips.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To delete this driver, first remove them from all assigned trips.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'View Trips',
            type: ButtonType.outline,
            onPressed: () {
              Navigator.pop(context);
              // You can implement navigation to trips page here
              CustomSnackBar.showInfo(
                context: context,
                message: 'Navigate to Trip Management to reassign ${driver.name}',
              );
            },
          ),
          CustomButton(
            text: 'Understood',
            type: ButtonType.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showUpdateDriverDialog(Driver driver) {
    final nameController = TextEditingController(text: driver.name);
    final phoneController = TextEditingController(text: driver.phoneNumber);
    final licenseController = TextEditingController(text: driver.licenseNumber);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return AlertDialog(
            title: const Text('Update Driver'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Full Name',
                    hint: 'Enter full name',
                    prefixIcon: Icons.person,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: licenseController,
                    label: 'License Number',
                    hint: 'Enter license number',
                    prefixIcon: Icons.credit_card,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  // Validate input
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      licenseController.text.trim().isEmpty) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please fill in all fields',
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    // Call the API to update the driver
                    await ref.read(driversProvider.notifier).updateDriver(
                      id: driver.id,
                      name: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      licenseNumber: licenseController.text.trim(),
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      CustomSnackBar.showSuccess(
                        context: context,
                        message: 'Driver updated successfully! Refreshing list...',
                      );
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    
                    if (mounted) {
                      CustomSnackBar.showError(
                        context: context,
                        message: 'Failed to update driver: ${e.toString()}',
                      );
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Update Driver'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTrackLocationDialog(Driver driver) {
    showDialog(
      context: context,
      builder: (context) => DriverLocationDialog(
        driver: driver,
      ),
    );
  }

  void _showDriverSelectionDialog(Bus bus) {
    showDialog(
      context: context,
      builder: (context) => DriverSelectionDialog(
        bus: bus,
      ),
    );
  }
} 