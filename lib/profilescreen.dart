import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_color.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColor.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              _buildPhoneField(),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primary), // Custom border color
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primary), // Custom border color when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primaryDark), // Custom border color when focused
          ),
          filled: true,
          fillColor: Colors.grey[200], // Optional: Add a light background color
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _phoneController,
        decoration: InputDecoration(
          labelText: 'Phone',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primary), // Custom border color
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primary), // Custom border color when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primaryDark), // Custom border color when focused
          ),
          filled: true,
          fillColor: Colors.grey[200], // Optional: Add a light background color
          prefixText: '+20 ',
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Required';
          if (value!.length != 10) return 'Must be 10 digits';
          return null;
        },
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Save logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }
}