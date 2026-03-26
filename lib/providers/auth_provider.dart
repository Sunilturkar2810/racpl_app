import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/error_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  late AuthService _authService;

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  AppError? _error;
  String? _lastSuccessMessage;

  AuthProvider({AuthService? authService}) {
    if (authService != null) {
      _authService = authService;
    }
  }

  // ============ Getters ============
  User? get currentUser => _currentUser;

  String? get token => _token;

  bool get isLoading => _isLoading;

  AppError? get error => _error;
  String? get lastSuccessMessage => _lastSuccessMessage;

  bool get isAuthenticated => _token != null && _currentUser != null;

  String get userName => _currentUser?.fullName ?? 'User';

  String get userEmail => _currentUser?.email ?? '';

  String get userRole => _currentUser?.role ?? 'Employee';

  // ============ Methods ============

  /// Set the auth service (for late initialization)
  void setAuthService(AuthService authService) {
    _authService = authService;
  }

  /// Initialize auth state (check if user is logged in)
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        // Try to fetch current user
        try {
          _currentUser = await _authService.getCurrentUser();
          _token = await _authService.getToken();
        } catch (e) {
          // Token might be expired, clear it
          await _authService.logout();
          _currentUser = null;
          _token = null;
        }
      }
    } catch (e) {
      _currentUser = null;
      _token = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login user
  Future<bool> login({required String email, required String password}) async {
    developer.log('🟡 [AuthProvider] Login started for: $email');

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      developer.log('🟡 [AuthProvider] Calling AuthService.login()...');
      final response = await _authService.login(
        email: email,
        password: password,
      );

      developer.log('🟢 [AuthProvider] Login successful!');
      developer.log('👤 User: ${response.user.fullName}');
      developer.log('🔐 Token: ${response.token.substring(0, 20)}...');

      _token = response.token;
      _currentUser = response.user;

      notifyListeners();
      return true;
    } catch (e) {
      developer.log('🔴 [AuthProvider] Login failed: $e');
      developer.log('🔴 [AuthProvider] Error type: ${e.runtimeType}');

      _error = e is AppError ? e : AppError(message: e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signup new user
  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String designation,
    required String department,
    required String joiningDate,
  }) async {
    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      _lastSuccessMessage = await _authService.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
        designation: designation,
        department: department,
        joiningDate: joiningDate,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = e is AppError ? e : AppError(message: e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _token = null;
      _error = null;
      _lastSuccessMessage = null;
    } catch (e) {
      _error = e is AppError ? e : AppError(message: e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update user theme
  Future<void> updateTheme(String theme) async {
    try {
      _error = null;
      await _authService.updateTheme(theme);

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(theme: theme);
        notifyListeners();
      }
    } catch (e) {
      _error = e is AppError ? e : AppError(message: e.toString());
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _lastSuccessMessage = null;
    notifyListeners();
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = e is AppError ? e : AppError(message: e.toString());
      notifyListeners();
    }
  }
}
