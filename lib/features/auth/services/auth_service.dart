import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/features/auth/models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://smarttrackingapp.runasp.net/api/Account';
  
  final Map<String, String> _headers = {
    'accept': 'text/plain',
    'Content-Type': 'application/json',
  };

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Create user model from response
        final user = UserModel(
          id: data['id'] ?? '',
          email: email,
          displayName: data['displayName'] ?? email.split('@')[0],
          userType: 'user',
          isEmailVerified: data['emailConfirmed'] ?? false,
          lastLoginAt: DateTime.now(),
        );

        return {
          'success': true,
          'user': user.toJson(),
          'token': data['token'] ?? '',
        };
      } else {
        return {
          'success': false,
          'error': 'Login failed: Wrong email or password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({
          'displayName': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Create user model from response
        final user = UserModel(
          id: data['id'] ?? '',
          email: email,
          displayName: name,
          userType: 'user',
          isEmailVerified: data['emailConfirmed'] ?? false,
          lastLoginAt: DateTime.now(),
        );

        return {
          'success': true,
          'user': user.toJson(),
          'token': data['token'] ?? '',
        };
      } else {
        final error = jsonDecode(response.body);
        final passwordErrors = error['errors']?['Password'];
        final emailErrors = error['errors']?['Email'];

        String errorMessage = 'Registration failed';
        if (passwordErrors != null && passwordErrors is List && passwordErrors.isNotEmpty) {
          errorMessage = passwordErrors.first;
        } else if (emailErrors != null && emailErrors is List && emailErrors.isNotEmpty) {
          errorMessage = emailErrors.first;
        } else if (error['title'] != null) {
          errorMessage = error['title'];
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Google login
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google-login'),
        headers: _headers,
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Create user model from response
        final user = UserModel(
          id: data['id'] ?? '',
          email: data['email'] ?? '',
          displayName: data['displayName'] ?? '',
          userType: 'user',
          isEmailVerified: data['emailConfirmed'] ?? true,
          lastLoginAt: DateTime.now(),
        );

        return {
          'success': true,
          'user': user.toJson(),
          'token': data['token'] ?? '',
        };
      } else {
        return {
          'success': false,
          'error': 'Google login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Google login error: $e',
      };
    }
  }

  // Reset password request
  Future<Map<String, dynamic>> resetPasswordRequest(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password-request'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'callbackUrl': 'smarttrackingapp://?email=$email&code={code}',
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Reset email sent successfully',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Email not found',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to send reset email',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to reset password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': 'Token refresh failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
} 