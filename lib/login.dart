import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_color.dart';
import 'package:flutter_application_1/component/buildTextField.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_1/component/snack.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  // Function to handle normal email/password login
  Future<void> _loginUser() async {
    final url = Uri.parse('http://smarttrackingapp.runasp.net/api/Account/login');
    final email = _inputController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackBarHelper.show(context, "All fields are required");
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      SnackBarHelper.show(context, "Enter a valid email address");
      return;
    }

    final body = jsonEncode({"email": email, "password": password});

    try {
      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token']; // Assuming the API returns a token in the response

        // Store token and login status in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_token', token);

        SnackBarHelper.show(context, "Login successful");
        Navigator.pushNamedAndRemoveUntil(context, '/newmap', (route) => false);
      } else {
        SnackBarHelper.show(context, "Login Failed: Wrong Email OR Password");
      }
    } catch (error) {
      SnackBarHelper.show(context, "Error during login: $error");
    }
  }

  // Function to handle Google login
  Future<void> _handleGoogleLogin() async {
    final googleSignIn = GoogleSignIn();
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        SnackBarHelper.show(context, "Google sign-in canceled");
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        SnackBarHelper.show(context, "Failed to get Google ID token");
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

        SnackBarHelper.show(context, "Google login successful");
        Navigator.pushNamedAndRemoveUntil(context, '/newmap', (route) => false);
      } else {
        SnackBarHelper.show(context, "Google login failed");
      }
    } catch (error) {
      SnackBarHelper.show(context, "Google sign-in error: $error");
    }
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
                'Welcome back you’ve been missed!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              CustomTextField(
                controller: _inputController,
                label: 'Email',
                hint: 'example@gmail.com',
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                isPassword: true,
              ),
              const SizedBox(height: 35),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/forgetpass"),
                child: Text('Forgot your password?',
                    style: TextStyle(color: AppColor.primary, fontSize: 16)),
              ),
              const Spacer(flex: 1),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF91A800),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Sign in',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
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
                    onPressed: _handleGoogleLogin,
                    icon: Image.asset('lib/image/g_logo.png', width: 40, height: 40),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text('Create new account',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
