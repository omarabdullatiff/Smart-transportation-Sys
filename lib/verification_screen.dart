import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; 
import 'package:flutter_application_1/app_color.dart';


class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String currentText = "";

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
                    onPressed: () {
                    Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              const Text(
                'Verification',
                style: TextStyle(
                  color:AppColor.primary,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Enter the code we sent to your email',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              // Replace the Row with PinCodeTextField
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 30),
                child: PinCodeTextField(
                  appContext: context,
                  pastedTextStyle: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 4,
                  obscureText: false,
                  blinkWhenObscuring: true,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    borderRadius: BorderRadius.circular(5),
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
                  //errorAnimationController: errorController,
                  controller: TextEditingController(),
                  keyboardType: TextInputType.number,
                  boxShadows: const [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                  onCompleted: (v) {
                    print("Completed");
                  },
                  onChanged: (value) {
                    setState(() {
                      currentText = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "If you didn't receive a code!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Resend code logic
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color:AppColor.primary,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Verify code logic
                    print("Entered Pin: $currentText"); // Print the entered PIN
                  },
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
