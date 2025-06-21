import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/routes/app_routes.dart';
import 'package:flutter_application_1/shared/widgets/custom_text_field.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isChecked = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _headers = const {
    'accept': 'text/plain',
    'Content-Type': 'application/json',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      CustomSnackBar.showError(
        context: context,
        message: "All fields are required",
      );
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      CustomSnackBar.showError(
        context: context,
        message: "Enter a valid email address",
      );
      return;
    }
    if (password != confirmPassword) {
      CustomSnackBar.showError(
        context: context,
        message: "Passwords do not match",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send registration request
      final response = await http.post(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Account/register'),
        headers: _headers,
        body: jsonEncode({
          "displayName": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackBar.showSuccess(
          context: context,
          message: "Registration successful",
        );
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.newMap, (route) => false);
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          final passwordErrors = error['errors']?['Password'];
          final emailErrors = error['errors']?['Email'];

          if (passwordErrors != null && passwordErrors is List && passwordErrors.isNotEmpty) {
            CustomSnackBar.showError(
              context: context,
              message: passwordErrors.first,
            );
          } else if (emailErrors != null && emailErrors is List && emailErrors.isNotEmpty) {
            CustomSnackBar.showError(
              context: context,
              message: emailErrors.first,
            );
          } else if (error['title'] != null) {
            CustomSnackBar.showError(
              context: context,
              message: error['title'],
            );
          } else {
            CustomSnackBar.showError(
              context: context,
              message: "Registration failed. Please check your input.",
            );
          }
        } catch (e) {
          CustomSnackBar.showError(
            context: context,
            message: "Unexpected error. Please try again.",
          );
        }
      }
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: "Network error. Please check your connection.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: AppColor.primary,
                ),
              ),
              Text(
                'Create new account',
                style: TextStyle(
                    fontSize: 16, color: AppColor.accent, letterSpacing: 2),
              ),
              const Spacer(flex: 1),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 50),
              _buildTermsCheckbox(),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Sign up',
                width: double.infinity,
                height: 56,
                isLoading: _isLoading,
                onPressed: (_isChecked && !_isLoading)
                    ? _registerUser
                    : () {
                        if (!_isChecked) {
                          CustomSnackBar.showWarning(
                            context: context,
                            message: 'Please agree to the Terms & Conditions and Privacy Policy.',
                          );
                        }
                      },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Already have an account? log in',
                type: ButtonType.text,
                onPressed: _isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.login),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: _isLoading ? null : (value) => setState(() => _isChecked = value ?? false),
          activeColor: AppColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
              children: [
                const TextSpan(text: 'I agree to the ', style: TextStyle(color: Colors.grey)),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: AppColor.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and ', style: TextStyle(color: Colors.grey)),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColor.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
