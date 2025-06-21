import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_text_field.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/shared/widgets/custom_card.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
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
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Active Trips',
            value: '24',
            icon: Icons.directions_bus,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Out of Service',
            value: '3',
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Paused',
            value: '2',
            icon: Icons.pause_circle,
            color: Colors.blue,
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
            const SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                title: 'Bulk Import',
                icon: Icons.upload_file,
                color: Colors.blue,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                title: 'Analytics',
                icon: Icons.analytics,
                color: Colors.purple,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Trips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            CustomButton(
              text: 'Filter',
              type: ButtonType.text,
              icon: Icons.filter_list,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildTripCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildTripCard(int index) {
    final statuses = ['Online', 'Out of Service', 'Paused', 'Online', 'Online'];
    final colors = [Colors.green, Colors.red, Colors.orange, Colors.green, Colors.green];
    final routes = [
      'Downtown → Airport',
      '5th Settlement → Heliopolis',
      'Maadi → New Cairo',
      'Zamalek → Dokki',
      'Nasr City → Tagamo3',
    ];

    return InfoCard(
      title: 'Trip ${index + 1} - Bus ${575 + index}',
      subtitle: '${routes[index]} • Every 15 min',
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
              color: colors[index].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statuses[index],
              style: TextStyle(
                color: colors[index],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleTripAction(value, index),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Trip'),
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

  Widget _buildDriverManagement() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildDriverStats() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Available',
            value: '12',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Driving',
            value: '8',
            icon: Icons.drive_eta,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Offline',
            value: '4',
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
            const SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                title: 'Bulk Assign',
                icon: Icons.assignment,
                color: Colors.orange,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                title: 'Track All',
                icon: Icons.my_location,
                color: Colors.green,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriversList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Drivers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildDriverCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildDriverCard(int index) {
    final statuses = ['Available', 'Driving', 'Offline', 'Available', 'Driving', 'Available'];
    final colors = [Colors.green, Colors.blue, Colors.grey, Colors.green, Colors.blue, Colors.green];
    final names = ['Ahmed Ali', 'Mohamed Hassan', 'Omar Khaled', 'Ali Ahmed', 'Hassan Omar', 'Khaled Mohamed'];
    final trips = ['Trip 1', 'Trip 3', 'Not Assigned', 'Trip 2', 'Trip 4', 'Not Assigned'];

    return InfoCard(
      title: names[index],
      subtitle: 'ID: DR${1000 + index} • ${trips[index]}',
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppColor.primary.withValues(alpha: 0.1),
        child: Text(
          names[index].split(' ').map((e) => e[0]).join(),
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
              color: colors[index].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statuses[index],
              style: TextStyle(
                color: colors[index],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleDriverAction(value, index),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Driver'),
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
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => FormDialog(
        title: 'Add New Driver',
        fields: [
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
          const SizedBox(height: 16),
          CustomTextField(
            controller: emailController,
            label: 'Email',
            hint: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email,
          ),
        ],
        onSave: () {
          Navigator.pop(context);
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Driver added successfully!',
          );
        },
      ),
    );
  }

  void _handleTripAction(String action, int index) {
    switch (action) {
      case 'edit':
        _showCreateTripDialog(); // Reuse dialog for editing
        break;
      case 'status':
        _showStatusDialog('Trip ${index + 1}');
        break;
      case 'assign':
        _showAssignDriverDialog('Trip ${index + 1}');
        break;
      case 'delete':
        _showDeleteConfirmation('Trip ${index + 1}');
        break;
    }
  }

  void _handleDriverAction(String action, int index) {
    switch (action) {
      case 'edit':
        _showAddDriverDialog(); // Reuse dialog for editing
        break;
      case 'assign':
        _showAssignTripDialog('Driver ${index + 1}');
        break;
      case 'track':
        CustomSnackBar.showInfo(
          context: context,
          message: 'Tracking Driver ${index + 1} location...',
        );
        break;
      case 'delete':
        _showDeleteConfirmation('Driver ${index + 1}');
        break;
    }
  }

  void _showStatusDialog(String tripName) {
    final items = [
      ListDialogItem(
        title: 'Set Online',
        value: 'online',
        icon: Icons.circle,
      ),
      ListDialogItem(
        title: 'Out of Service',
        value: 'out_of_service',
        icon: Icons.circle,
      ),
      ListDialogItem(
        title: 'Pause',
        value: 'pause',
        icon: Icons.pause_circle,
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => ListDialog<String>(
        title: 'Change Status - $tripName',
        items: items,
        onItemSelected: (value) {
          String message = '';
          switch (value) {
            case 'online':
              message = '$tripName set to Online';
              break;
            case 'out_of_service':
              message = '$tripName marked as Out of Service';
              break;
            case 'pause':
              message = '$tripName paused';
              break;
          }
          CustomSnackBar.showSuccess(
            context: context,
            message: message,
          );
        },
      ),
    );
  }

  void _showAssignDriverDialog(String tripName) {
    final drivers = List.generate(
      5,
      (index) => ListDialogItem(
        title: 'Driver ${index + 1}',
        subtitle: 'Available',
        value: index,
        icon: Icons.person,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => ListDialog<int>(
        title: 'Assign Driver - $tripName',
        items: drivers,
        onItemSelected: (driverIndex) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Driver ${driverIndex + 1} assigned to $tripName',
          );
        },
      ),
    );
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

  void _showDeleteConfirmation(String itemName) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete $itemName?',
      confirmText: 'Delete',
      confirmType: ButtonType.danger,
      icon: Icons.delete,
      iconColor: Colors.red,
    );

    if (confirmed == true && mounted) {
      CustomSnackBar.showSuccess(
        context: context,
        message: '$itemName deleted successfully',
      );
    }
  }
} 