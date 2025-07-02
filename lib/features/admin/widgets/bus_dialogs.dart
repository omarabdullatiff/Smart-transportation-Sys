import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_text_field.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/features/admin/providers/buses_provider.dart';
import 'package:flutter_application_1/features/admin/models/bus_model.dart';
import 'package:flutter_application_1/features/admin/screens/driver_selection_dialog.dart';
import 'package:flutter_application_1/features/admin/screens/create_bus_dialog.dart';

class BusDialogs {
  static void handleBusAction(BuildContext context, WidgetRef ref, String action, Bus bus) {
    switch (action) {
      case 'edit':
        showEditBusDialog(context, ref, bus);
        break;
      case 'status':
        showBusStatusDialog(context, ref, bus);
        break;
      case 'assign':
        showDriverSelectionDialog(context, bus);
        break;
      case 'assignTrip':
        showAssignBusToTripDialog(context, ref, bus);
        break;
      case 'unassignTrip':
        showUnassignBusFromTripDialog(context, ref, bus);
        break;
      case 'unassign':
        showUnassignDriverConfirmation(context, ref, bus);
        break;
      case 'delete':
        showDeleteBusConfirmation(context, ref, bus);
        break;
    }
  }

  static void showCreateBusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateBusDialog(),
    );
  }

  static void showDriverSelectionDialog(BuildContext context, Bus bus) {
    showDialog(
      context: context,
      builder: (context) => DriverSelectionDialog(
        bus: bus,
      ),
    );
  }

  static void showEditBusDialog(BuildContext context, WidgetRef ref, Bus bus) {
    final modelController = TextEditingController(text: bus.model);
    final capacityController = TextEditingController(text: bus.capacity.toString());
    BusStatus selectedStatus = bus.busStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return AlertDialog(
            title: Text('Edit Bus ${bus.licensePlate}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: modelController,
                    label: 'Bus Model',
                    hint: 'Enter bus model',
                    prefixIcon: Icons.directions_bus,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: capacityController,
                    label: 'Capacity',
                    hint: 'Enter passenger capacity',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.airline_seat_recline_normal,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BusStatus>(
                            value: selectedStatus,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            onChanged: (BusStatus? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              }
                            },
                            items: BusStatus.values.map((BusStatus status) {
                              return DropdownMenuItem<BusStatus>(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(status.stringValue),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
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
                  if (modelController.text.trim().isEmpty ||
                      capacityController.text.trim().isEmpty) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please fill in all fields',
                    );
                    return;
                  }

                  final capacity = int.tryParse(capacityController.text.trim());
                  if (capacity == null || capacity <= 0) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please enter a valid capacity',
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    // Call the API to update the bus
                    await ref.read(busesProvider.notifier).updateBus(
                      id: bus.id,
                      licensePlate: bus.licensePlate,
                      model: modelController.text.trim(),
                      capacity: capacity,
                      status: selectedStatus.stringValue,
                      origin: bus.origin,
                      destination: bus.destination,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      CustomSnackBar.showSuccess(
                        context: context,
                        message: 'Bus ${bus.licensePlate} updated successfully! Refreshing list...',
                      );
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    
                    if (context.mounted) {
                      CustomSnackBar.showError(
                        context: context,
                        message: 'Failed to update bus: ${e.toString()}',
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
                    : const Text('Update Bus'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showBusStatusDialog(BuildContext context, WidgetRef ref, Bus bus) {
    final items = [
      ListDialogItem(
        title: 'Active',
        value: 0,
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
            CustomSnackBar.showInfo(
              context: context,
              message: 'Updating ${bus.licensePlate} status...',
            );

            final success = await ref.read(busesProvider.notifier).changeBusStatus(
              bus.id,
              statusValue,
            );

            if (success && context.mounted) {
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
            if (context.mounted) {
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

  static void showAssignBusToTripDialog(BuildContext context, WidgetRef ref, Bus bus) {
    final tripIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return AlertDialog(
            title: Text('Assign Bus ${bus.licensePlate} to Trip'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the Trip ID to assign this bus to:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: tripIdController,
                    label: 'Trip ID',
                    hint: 'Enter trip ID (e.g., 205)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.route,
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
                  if (tripIdController.text.trim().isEmpty) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please enter a trip ID',
                    );
                    return;
                  }

                  final tripId = int.tryParse(tripIdController.text.trim());
                  if (tripId == null || tripId <= 0) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please enter a valid trip ID',
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    final success = await ref.read(busesProvider.notifier).assignBusToTrip(
                      tripId,
                      bus.id,
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      CustomSnackBar.showSuccess(
                        context: context,
                        message: 'Bus ${bus.licensePlate} assigned to Trip $tripId successfully!',
                      );
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    
                    if (context.mounted) {
                      CustomSnackBar.showError(
                        context: context,
                        message: 'Failed to assign bus to trip: ${e.toString()}',
                      );
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Assign to Trip'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showUnassignBusFromTripDialog(BuildContext context, WidgetRef ref, Bus bus) {
    final tripIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return AlertDialog(
            title: Text('Unassign Bus ${bus.licensePlate} from Trip'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the Trip ID to unassign this bus from:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: tripIdController,
                    label: 'Trip ID',
                    hint: 'Enter trip ID (e.g., 205)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.route_outlined,
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
                  if (tripIdController.text.trim().isEmpty) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please enter a trip ID',
                    );
                    return;
                  }

                  final tripId = int.tryParse(tripIdController.text.trim());
                  if (tripId == null || tripId <= 0) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Please enter a valid trip ID',
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    final success = await ref.read(busesProvider.notifier).unassignBusFromTrip(
                      tripId,
                      bus.id,
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      CustomSnackBar.showSuccess(
                        context: context,
                        message: 'Bus ${bus.licensePlate} unassigned from Trip $tripId successfully!',
                      );
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    
                    if (context.mounted) {
                      CustomSnackBar.showError(
                        context: context,
                        message: 'Failed to unassign bus from trip: ${e.toString()}',
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Unassign from Trip',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showDeleteBusConfirmation(BuildContext context, WidgetRef ref, Bus bus) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete bus ${bus.licensePlate}?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      confirmType: ButtonType.danger,
      icon: Icons.delete,
      iconColor: Colors.red,
    );

    if (confirmed == true && context.mounted) {
      try {
        CustomSnackBar.showInfo(
          context: context,
          message: 'Deleting bus ${bus.licensePlate}...',
        );

        final success = await ref.read(busesProvider.notifier).deleteBus(bus.id);

        if (success && context.mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Bus ${bus.licensePlate} deleted successfully!',
          );
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.showError(
            context: context,
            message: 'Failed to delete bus ${bus.licensePlate}: ${e.toString()}',
          );
        }
      }
    }
  }

  static void showUnassignDriverConfirmation(BuildContext context, WidgetRef ref, Bus bus) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Unassign Driver',
      message: 'Are you sure you want to unassign the driver from bus ${bus.licensePlate}?\n\nThe bus will become available for assignment.',
      confirmText: 'Unassign',
      confirmType: ButtonType.secondary,
      icon: Icons.person_remove,
      iconColor: Colors.orange,
    );

    if (confirmed == true && context.mounted) {
      try {
        CustomSnackBar.showInfo(
          context: context,
          message: 'Unassigning driver from bus ${bus.licensePlate}...',
        );

        final success = await ref.read(busesProvider.notifier).unassignDriverFromBus(bus.id);

        if (success && context.mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Driver unassigned from bus ${bus.licensePlate} successfully!',
          );
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.showError(
            context: context,
            message: 'Failed to unassign driver from bus ${bus.licensePlate}: ${e.toString()}',
          );
        }
      }
    }
  }

  static Color _getStatusColor(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return Colors.green;
      case BusStatus.inactive:
        return Colors.grey;
      case BusStatus.maintenance:
        return Colors.orange;
      case BusStatus.outOfService:
        return Colors.red;
    }
  }
}
