import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/routes/app_routes.dart';
import 'package:flutter_application_1/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/shared/widgets/custom_text_field.dart';
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

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _logoAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  final _headers = const {
    'accept': 'text/plain',
    'Content-Type': 'application/json',
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _animationController.forward();
    _logoAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  // Function to handle normal email/password login
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if admin login
      if (email == 'omar@admin.com') {
        if (password.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('auth_token', 'admin_token_placeholder');
          await prefs.setString('user_type', 'admin');

          _showSuccessSnackBar("Admin login successful");
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.adminDashboard, (route) => false);
          }
          return;
        }
      }
      
      if (email == 'omar1@driver.com') {
        if (password.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('auth_token', 'driver_token_placeholder');
          await prefs.setString('user_type', 'driver');

          _showSuccessSnackBar("Driver login successful");
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.driver, (route) => false);
          }
          return;
        }
      }

      // Regular user login with API
      final url =
          Uri.parse('http://smarttrackingapp.runasp.net/api/Account/login');
      final body = jsonEncode({"email": email, "password": password});

      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];

        // Store token and login status in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_token', token);
        await prefs.setString('user_type', 'user');

        _showSuccessSnackBar("Login successful");
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.newMap, (route) => false);
        }
      } else {
        _showErrorSnackBar("Login Failed: Wrong Email OR Password");
      }
    } catch (error) {
      _showErrorSnackBar("Error during login. Please try again.");
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
      _isGoogleLoading = true;
    });

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        _showWarningSnackBar("Google sign-in canceled");
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        _showErrorSnackBar("Failed to get Google ID token");
        return;
      }

      final url = Uri.parse(
          'http://smarttrackingapp.runasp.net/api/Account/google-login');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];

        // Store token and login status in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_token', token);
        await prefs.setString('user_type', 'user');

        _showSuccessSnackBar("Google login successful");
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.newMap, (route) => false);
        }
      } else {
        _showErrorSnackBar("Google login failed");
      }
    } catch (error) {
      _showErrorSnackBar("Google sign-in error. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // Logo/Icon with animation
        AnimatedBuilder(
          animation: _logoAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoScaleAnimation.value,
              child: Transform.rotate(
                angle: _logoRotationAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    size: 50,
                    color: AppColor.primary,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Welcome text
        const Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Sign in to continue your journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          
          const SizedBox(height: 20),
          
          // Password field
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: _validatePassword,
          ),
          
          const SizedBox(height: 16),
          
          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Forgot Password?',
              type: ButtonType.text,
              onPressed: _isLoading
                  ? null
                  : () => Navigator.pushNamed(context, AppRoutes.forgetPass),
              textColor: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider with OR text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Google sign in button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (_isLoading || _isGoogleLoading) ? null : _handleGoogleLogin,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGoogleLoading) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      Image.asset(
                        'lib/image/g_logo.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _isGoogleLoading ? Colors.grey.shade600 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Welcome section
                    _buildWelcomeSection(),
                    
                    const SizedBox(height: 48),
                    
                    // Login form
                    _buildLoginForm(),
                    
                    const SizedBox(height: 32),
                    
                    // Sign in button
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _loginUser,
                      isLoading: _isLoading,
                      width: double.infinity,
                      height: 56,
                      icon: Icons.login,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Social login
                    _buildSocialLogin(),
                    
                    const SizedBox(height: 32),
                    
                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        CustomButton(
                          text: 'Sign Up',
                          type: ButtonType.text,
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pushNamed(context, AppRoutes.signup),
                          textColor: AppColor.primary,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Demo accounts info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Demo Accounts',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Admin: omar@admin.com\nDriver: omar1@driver.com\nUse any password',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
