import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/features/auth/models/user_model.dart';
import 'package:flutter_application_1/features/auth/services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AuthState());

  // Initialize from storage (check if user is already logged in)
  Future<void> initializeFromStorage() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final token = prefs.getString('auth_token');
      final userType = prefs.getString('user_type') ?? 'user';

      if (isLoggedIn && token != null) {
        // Create user from stored data
        final user = UserModel(
          id: prefs.getString('user_id') ?? '',
          email: prefs.getString('user_email') ?? '',
          displayName: prefs.getString('user_name') ?? '',
          userType: userType,
        );

        state = state.copyWith(
          isLoggedIn: true,
          user: user,
          token: token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize auth state: $e',
      );
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check for admin login
      if (email == 'omar@admin.com' && password.isNotEmpty) {
        final adminUser = UserModel(
          id: 'admin_001',
          email: email,
          displayName: 'Admin User',
          userType: 'admin',
        );

        await _saveUserData(adminUser, 'admin_token_placeholder');
        
        state = state.copyWith(
          isLoggedIn: true,
          user: adminUser,
          token: 'admin_token_placeholder',
          isLoading: false,
        );
        return true;
      }

      // Regular user login
      final result = await _authService.login(email, password);
      
      if (result['success'] == true) {
        final user = UserModel.fromJson(result['user']);
        final token = result['token'];

        await _saveUserData(user, token);

        state = state.copyWith(
          isLoggedIn: true,
          user: user,
          token: token,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login error: $e',
      );
      return false;
    }
  }

  // Register new user
  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register(name, email, password);
      
      if (result['success'] == true) {
        final user = UserModel.fromJson(result['user']);
        final token = result['token'];

        await _saveUserData(user, token);

        state = state.copyWith(
          isLoggedIn: true,
          user: user,
          token: token,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration error: $e',
      );
      return false;
    }
  }

  // Google login
  Future<bool> loginWithGoogle(String idToken) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.googleLogin(idToken);
      
      if (result['success'] == true) {
        final user = UserModel.fromJson(result['user']);
        final token = result['token'];

        await _saveUserData(user, token);

        state = state.copyWith(
          isLoggedIn: true,
          user: user,
          token: token,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Google login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google login error: $e',
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout error: $e',
      );
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Update user data in storage
      await _saveUserData(updatedUser, state.token!);

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Profile update error: $e',
      );
      return false;
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('auth_token', token);
    await prefs.setString('user_type', user.userType);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.displayName);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService, ref);
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userType == 'admin';
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
}); 