import 'dart:developer' as developer;
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../utils/storage_helper.dart';
import 'dio_service.dart';

class AuthService {
  final DioService _dioService;
  final StorageHelper _storage;

  AuthService({required DioService dioService, required StorageHelper storage})
    : _dioService = dioService,
      _storage = storage;

  /// Register new employee
  Future<String> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String designation,
    required String department,
    required String joiningDate,
  }) async {
    final request = SignupRequest(
      firstName: firstName,
      lastName: lastName,
      workEmail: email,
      password: password,
      role: role,
      designation: designation,
      department: department,
      joiningDate: joiningDate,
    );

    final response = await _dioService.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response['message']?.toString() ?? 'User registered successfully';
  }

  /// Login user with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    developer.log('🟡 [AuthService] Login request: email=$email');

    final request = LoginRequest(workEmail: email, password: password);

    developer.log('🟡 [AuthService] Sending POST /auth/login...');
    final response = await _dioService.post<AuthResponse>(
      '/auth/login',
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    developer.log('🟢 [AuthService] Login API response received!');

    // Save user data locally
    await _storage.saveUserData(
      userId: response.user.id,
      email: response.user.email,
      name: response.user.fullName,
      role: response.user.role,
    );

    developer.log('✅ [AuthService] User data saved locally');

    // Save token
    await _storage.saveToken(response.token);
    developer.log('✅ [AuthService] Token saved locally');

    return response;
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    return await _dioService.get<User>(
      '/auth/me',
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update user theme preference
  Future<void> updateTheme(String theme) async {
    await _dioService.put<Map<String, dynamic>>(
      '/auth/theme',
      data: {'theme': theme},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Logout (clear local token and user data)
  Future<void> logout() async {
    await _storage.clearAll();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  /// Refresh token (optional - for future implementation)
  Future<void> refreshToken() async {
    // To be implemented based on backend support
  }
}
