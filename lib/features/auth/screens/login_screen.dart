import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/routes/app_routes.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/shared/widgets/custom_snackbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _headers = const {
    'accept': 'text/plain',
    'Content-Type': 'application/json',
  };

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Function to handle normal email/password login
  Future<void> _loginUser() async {
    final email = _inputController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if admin login
      if (email == 'omar@admin.com') {
        // For admin, just check if password is not empty (you can add more validation)
        if (password.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('auth_token', 'admin_token_placeholder');
          await prefs.setString('user_type', 'admin');
          
          CustomSnackBar.showSuccess(
            context: context,
            message: "Admin login successful",
          );
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminDashboard, (route) => false);
          }
          return;
        } else {
          CustomSnackBar.showError(
            context: context,
            message: "Password is required",
          );
          return;
        }
      }

      // Regular user login with API
      final url = Uri.parse('http://smarttrackingapp.runasp.net/api/Account/login');
      final body = jsonEncode({"email": email, "password": password});

      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token']; // Assuming the API returns a token in the response

        // Store token and login status in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_token', token);
        await prefs.setString('user_type', 'user');

        CustomSnackBar.showSuccess(
          context: context,
          message: "Login successful",
        );
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.newMap, (route) => false);
        }
      } else {
        CustomSnackBar.showError(
          context: context,
          message: "Login Failed: Wrong Email OR Password",
        );
      }
    } catch (error) {
      CustomSnackBar.showError(
        context: context,
        message: "Error during login: $error",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Function to handle Google login
  Future<void> _handleGoogleLogin() async {
    final googleSignIn = GoogleSignIn();
    
    setState(() {
      _isLoading = true;
    });

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        CustomSnackBar.showWarning(
          context: context,
          message: "Google sign-in canceled",
        );
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        CustomSnackBar.showError(
          context: context,
          message: "Failed to get Google ID token",
        );
        return;
      }

      final url = Uri.parse('http://smarttrackingapp.runasp.net/api/Account/google-login');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'idToken': idToken}), // Send the ID token
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token']; // Assuming 'token' is in the response

        // Store token and login status in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_token', token);
        await prefs.setString('user_type', 'user');

        CustomSnackBar.showSuccess(
          context: context,
          message: "Google login successful",
        );
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.newMap, (route) => false);
        }
      } else {
        CustomSnackBar.showError(
          context: context,
          message: "Google login failed",
        );
      }
    } catch (error) {
      CustomSnackBar.showError(
        context: context,
        message: "Google sign-in error: $error",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.7),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColor.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16, 
            horizontal: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: _togglePasswordVisibility,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 155, 179, 1),
                ),
              ),
              const Text(
                "Welcome back you've been missed!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              _buildStyledTextField(
                controller: _inputController,
                labelText: 'Email',
                hintText: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildStyledTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                isPassword: true,
              ),
              const SizedBox(height: 35),
              CustomButton(
                text: 'Forgot your password?',
                type: ButtonType.text,
                onPressed: _isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.forgetPass),
              ),
              const Spacer(flex: 1),
              CustomButton(
                text: 'Sign in',
                width: double.infinity,
                height: 56,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _loginUser,
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: Opacity(
                      opacity: _isLoading ? 0.5 : 1.0,
                      child: Image.asset('lib/image/g_logo.png', width: 40, height: 40),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Create new account',
                type: ButtonType.text,
                onPressed: _isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.signup),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
