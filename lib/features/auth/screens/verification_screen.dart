// verification_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'change_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String currentText = "";
  bool _isLoading = false;
  String? email;

  Future<void> _verifyCode() async {
    if (currentText.length != 4 || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Normally, you'd call a verification API.
    // But if you use the same API during reset-password, then skip check.
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(
            email: email!,
            code: currentText,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      email = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 16.0),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              const Text(
                'Verification',
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Enter the code sent to your email',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.grey.shade300,
                    selectedFillColor: Colors.white,
                    activeColor: AppColor.primary,
                    inactiveColor: Colors.grey.shade300,
                    selectedColor: AppColor.primary,
                  ),
                  cursorColor: Colors.black,
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  controller: TextEditingController(),
                  keyboardType: TextInputType.number,
                  onCompleted: (v) {
                    currentText = v;
                  },
                  onChanged: (value) {
                    setState(() => currentText = value);
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // إعادة إرسال الكود (إعادة استخدام صفحة ForgetPass مثلاً)
                  Navigator.pop(context);
                },
                child: const Text(
                  'Didn\'t receive code? Resend',
                  style: TextStyle(color: AppColor.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
