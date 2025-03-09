import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_color.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isEmailLogin = true; // Toggle between email and phone login
  final TextEditingController _inputController = TextEditingController();

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
              Spacer(flex: 2),
              // Header Text
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 155, 179, 1),
                ),
              ),
              Text(
                'Welcome back you’ve been missed!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 1),
              // Toggle between Email and Phone Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  // Email Toggle Button
                  ChoiceChip(
                    label: Text('Email'),
                    selected: _isEmailLogin,
                    onSelected: (selected) {
                      setState(() {
                        _isEmailLogin = true;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  // Phone Toggle Button
                  ChoiceChip(
                    label: Text('Phone'),
                    selected: !_isEmailLogin,
                    onSelected: (selected) {
                      setState(() {
                        _isEmailLogin = false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Dynamic Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    labelText: _isEmailLogin ? 'Email' : 'Phone Number',
                    hintText: _isEmailLogin
                        ? 'example@gmail.com'
                        : 'Enter your phone number',
                    labelStyle: TextStyle(
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
                      borderSide:
                          BorderSide(color: Color(0xFF91A800), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  keyboardType: _isEmailLogin
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                ),
              ),
              SizedBox(height: 15),
              // Password Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    labelStyle: TextStyle(
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
                      borderSide:
                          BorderSide(color: Color(0xFF91A800), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              SizedBox(height: 35),
              // Forgot Password Text
              TextButton(
                  onPressed: () {  
                    Navigator.pushNamed(context ,"/forgetpass");
                  },
                  child: Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                    ),
                  )),

              Spacer(flex: 1),
              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/booking');
                    // Add login logic here
                    final input = _inputController.text;
                    if (_isEmailLogin) {
                      // Handle email login
                      print('Logging in with email: $input');
                    } else {
                      // Handle phone login
                      print('Logging in with phone: $input');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF91A800),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Login with Google and Phone Number IconButtons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google IconButton
                  IconButton(
                    onPressed: () {
                      // Add Google login logic here
                    },
                    icon: Image.asset(
                      'lib/image/g_logo.png', // Path to Google icon
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(width: 20),
                  // Phone IconButton
                  IconButton(
                    onPressed: () {
                      // Add Phone login logic here
                    },
                    icon: Image.asset(
                      'lib/image/g_logo.png', // Path to Phone icon
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Create New Account TextButton
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'Create new account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
