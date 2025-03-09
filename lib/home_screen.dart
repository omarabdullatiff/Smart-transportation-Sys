import 'package:flutter/material.dart';
import 'app_color.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/image/navigatorgirl.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 80),
              Text(
                'Track It, Catch It, Love It',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColor.text,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'From Start to Finish, We\'ve Got You Covered',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.text,
                ),
              ),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: AppColor.primary,
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(color: AppColor.background),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: AppColor.primary,
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: AppColor.background),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
