import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_text_field.dart';
import 'package:flutter_application_1/shared/widgets/custom_dialog.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/features/admin/providers/drivers_provider.dart';
import 'package:flutter_application_1/features/admin/models/driver_model.dart';
import 'package:flutter_application_1/features/admin/screens/driver_location_dialog.dart';

class DriverDialogs {
  static void handleDriverAction(BuildContext context, WidgetRef ref, String action, Driver driver) {
    switch (action) {
      case 'update':
        showUpdateDriverDialog(context, ref, driver);
        break;
      case 'assign':
        showAssignTripDialog(context, driver.name);
        break;
      case 'track':
        showTrackLocationDialog(context, driver);
        break;
      case 'delete':
        showDeleteDriverConfirmation(context, ref, driver);
        break;
    }
  }

  static void showAddDriverDialog(BuildContext context) {
    // This function was in the main file but references DriverDialogs
    // We'll need to extract this from the main file
    showDialog(
      context: context,
      builder: (context) => const AddDriverDialog(),
    );
  }

  static void showUpdateDriverDialog(BuildContext context, WidgetRef ref, Driver driver) {
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

                    if (context.mounted) {
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
                    
                    if (context.mounted) {
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

  static void showAssignTripDialog(BuildContext context, String driverName) {
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

  static void showDeleteDriverConfirmation(BuildContext context, WidgetRef ref, Driver driver) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete ${driver.name}?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      confirmType: ButtonType.danger,
      icon: Icons.delete,
      iconColor: Colors.red,
    );

    if (confirmed == true && context.mounted) {
      try {
        // Show loading indicator
        CustomSnackBar.showInfo(
          context: context,
          message: 'Deleting ${driver.name}...',
        );

        // Call the API to delete the driver
        final success = await ref.read(driversProvider.notifier).deleteDriver(driver.id);

        if (success && context.mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: '${driver.name} deleted successfully! Refreshing list...',
          );
        }
      } catch (e) {
        if (context.mounted) {
          String errorMessage = _getDeleteErrorMessage(e.toString(), driver.name);
          
          if (e.toString().contains('DRIVER_HAS_TRIPS')) {
            // Show a more detailed dialog for this specific case
            _showDriverHasTripsDialog(context, driver);
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

  static String _getDeleteErrorMessage(String error, String driverName) {
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

  static void _showDriverHasTripsDialog(BuildContext context, Driver driver) {
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

  static void showTrackLocationDialog(BuildContext context, Driver driver) {
    showDialog(
      context: context,
      builder: (context) => DriverLocationDialog(
        driver: driver,
      ),
    );
  }
}

// Placeholder widget - we'll need to extract this from the main file
class AddDriverDialog extends StatefulWidget {
  const AddDriverDialog({super.key});

  @override
  State<AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<AddDriverDialog> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final licenseController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
        Consumer(
          builder: (context, ref, child) {
            return ElevatedButton(
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
            );
          },
        ),
      ],
    );
  }
}
