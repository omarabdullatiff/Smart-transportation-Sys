import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_color.dart';
import 'package:flutter_application_1/component/buildTextField.dart';
import 'package:flutter_application_1/component/snack.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isChecked = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _headers = const {
    'accept': 'text/plain',
    'Content-Type': 'application/json',
  };
  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      SnackBarHelper.show(context,"All fields are required");
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      SnackBarHelper.show(context,"Enter a valid email address");
      return;
    }
    if (password != confirmPassword) {
      SnackBarHelper.show(context,"Passwords do not match");
      return;
    }
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
      SnackBarHelper.show(context,"Registration successful", backgroundColor: Colors.green);
      Navigator.pushNamed(context, '/newmap');
    } else {
      try {
        final error = jsonDecode(response.body);
        final passwordErrors = error['errors']?['Password'];
        final emailErrors = error['errors']?['Email'];

        if (passwordErrors != null && passwordErrors is List && passwordErrors.isNotEmpty) {
          SnackBarHelper.show(context,passwordErrors.first);
        } else if (emailErrors != null && emailErrors is List && emailErrors.isNotEmpty) {
          SnackBarHelper.show(context,emailErrors.first);
        } else if (error['title'] != null) {
          SnackBarHelper.show(context,error['title']);
        } else {
          SnackBarHelper.show(context,"Registration failed. Please check your input.");
        }
      } catch (e) {
        SnackBarHelper.show(context,"Unexpected error. Please try again.");
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
                  controller: _nameController,
                  label: 'User Name',
                  hint: 'Enter Your Full Name'),
              const SizedBox(height: 20),
              CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'example@gmail.com'),
              const SizedBox(height: 20),
              CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  isPassword: true),
              const SizedBox(height: 20),
              CustomTextField(controller: _confirmPasswordController,
                  label: 'Confirm password',
                  hint: 'Confirm your password',
                  isPassword: true),
              const SizedBox(height: 50),
              _buildTermsCheckbox(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecked
                      ? _registerUser
                      : () =>
                      SnackBarHelper.show(context,
                          'Please agree to the Terms & Conditions and Privacy Policy.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF91A800),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Sign up',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text(
                  'Already have an account? log in ',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
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
          onChanged: (value) => setState(() => _isChecked = value ?? false),
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
  //
  // Widget _buildTermsCheckbox() {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 24,
  //         height: 24,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(6),
  //           border: Border.all(
  //             color: _isChecked ? AppColor.primary : Colors.grey,
  //             width: 2,
  //           ),
  //           color: _isChecked ? AppColor.primary : Colors.transparent,
  //         ),
  //         child: Theme(
  //           data: ThemeData(unselectedWidgetColor: Colors.transparent),
  //           child: Checkbox(
  //             value: _isChecked,
  //             onChanged: (bool? value) => setState(() => _isChecked = value ?? false),
  //             activeColor: Colors.transparent,
  //             checkColor: Colors.white,
  //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       Expanded(
  //         child: RichText(
  //           text: TextSpan(
  //             children: [
  //               const TextSpan(
  //                 text: 'I agree to the ',
  //                 style: TextStyle(fontSize: 16, color: Colors.grey),
  //               ),
  //               TextSpan(
  //                 text: 'Terms & Conditions',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: AppColor.primary,
  //                   decoration: TextDecoration.underline,
  //                 ),
  //               ),
  //               const TextSpan(
  //                 text: ' and ',
  //                 style: TextStyle(fontSize: 16, color: Colors.grey),
  //               ),
  //               TextSpan(
  //                 text: 'Privacy Policy',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: AppColor.primary,
  //                   decoration: TextDecoration.underline,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
