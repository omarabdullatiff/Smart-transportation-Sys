import 'package:flutter/material.dart'; 
import 'package:flutter_application_1/models/lost_items.dart';
import 'package:flutter_application_1/services/lost_items_service.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportItemPageState createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  DateTime? _selectedDateTime;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    TimeOfDay? pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedDate != null && pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Report an Item',
          style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? Icon(Icons.upload, size: 50, color: Colors.black54)
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField('Bus Number', _busNumberController, keyboardType: TextInputType.number),
                    _buildTextField('Description', _descriptionController),
                    _buildDateTimePicker(context),
                    _buildTextField('Name', _nameController),
                    _buildTextField('Phone', _phoneController, keyboardType: TextInputType.phone),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryDark,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () async {
                    if (_selectedDateTime == null || _busNumberController.text.isEmpty || _descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    final lostItem = LostItem(
                      busNumber: _busNumberController.text,
                      description: _descriptionController.text,
                      dateLost: _selectedDateTime!,
                      reporterName: _nameController.text,
                      reporterPhone: _phoneController.text,
                      photoUrl: _selectedImage?.path ?? '', // Use local image path
                    );

                    final success = await LostItemsService.reportLostItem(lostItem);

                    if (success) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item reported successfully!')),
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to report item')),
                      );
                    }
                  },
                  child: Text(
                    'CONFIRM',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.name}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColor.primaryDark, fontSize: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColor.primaryDark),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide(color: AppColor.primaryDark, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        readOnly: true,
        onTap: () => _pickDateTime(context),
        controller: TextEditingController(
          text: _selectedDateTime == null
              ? ''
              : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Date & Time',
          labelStyle: const TextStyle(color: AppColor.primaryDark, fontSize: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColor.primaryDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide(color: AppColor.primaryDark, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          suffixIcon: Icon(Icons.calendar_today, color: AppColor.primaryDark),
        ),
      ),
    );
  }
}