import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/shared/widgets/custom_text_field.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';
import 'package:flutter_application_1/features/admin/models/bus_model.dart';
import 'package:flutter_application_1/features/admin/providers/buses_provider.dart';

class CreateBusDialog extends ConsumerStatefulWidget {
  const CreateBusDialog({super.key});

  @override
  ConsumerState<CreateBusDialog> createState() => _CreateBusDialogState();
}

class _CreateBusDialogState extends ConsumerState<CreateBusDialog> {
  final _modelController = TextEditingController();
  final _capacityController = TextEditingController();
  BusStatus _selectedStatus = BusStatus.active;
  bool _isLoading = false;

  @override
  void dispose() {
    _modelController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.directions_bus,
                        color: AppColor.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Create New Bus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _modelController,
                  label: 'Bus Model',
                  hint: 'e.g., Volvo, Mercedes, Toyota',
                  prefixIcon: Icons.directions_bus_filled,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bus model is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _capacityController,
                  label: 'Capacity',
                  hint: 'Number of passengers',
                  prefixIcon: Icons.people,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Capacity is required';
                    }
                    final capacity = int.tryParse(value.trim());
                    if (capacity == null || capacity <= 0) {
                      return 'Please enter a valid capacity';
                    }
                    if (capacity > 100) {
                      return 'Capacity cannot exceed 100 passengers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
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
                            Icons.toggle_on,
                            color: AppColor.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Bus Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<BusStatus>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: BusStatus.values.map((status) {
                          return DropdownMenuItem<BusStatus>(
                            value: status,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Text(
                                    status.stringValue,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (BusStatus? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedStatus = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        type: ButtonType.outline,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Create Bus',
                        type: ButtonType.primary,
                        icon: Icons.add,
                        isLoading: _isLoading,
                        onPressed: _createBus,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BusStatus status) {
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

  Future<void> _createBus() async {
    // Validate inputs
    final model = _modelController.text.trim();
    final capacityText = _capacityController.text.trim();

    if (model.isEmpty) {
      CustomSnackBar.showError(
        context: context,
        message: 'Please enter the bus model',
      );
      return;
    }

    if (capacityText.isEmpty) {
      CustomSnackBar.showError(
        context: context,
        message: 'Please enter the bus capacity',
      );
      return;
    }

    final capacity = int.tryParse(capacityText);
    if (capacity == null || capacity <= 0) {
      CustomSnackBar.showError(
        context: context,
        message: 'Please enter a valid capacity',
      );
      return;
    }

    if (capacity > 100) {
      CustomSnackBar.showError(
        context: context,
        message: 'Capacity cannot exceed 100 passengers',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the bus using the provider
      await ref.read(busesProvider.notifier).createBus(
        model: model,
        capacity: capacity,
        status: _selectedStatus.stringValue,
      );

      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Bus "$model" created successfully! Refreshing list...',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Failed to create bus: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 