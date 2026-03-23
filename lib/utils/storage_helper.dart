import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';

  late SharedPreferences _preferences;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Save JWT token
  Future<bool> saveToken(String token) async {
    return await _preferences.setString(_tokenKey, token);
  }

  /// Get JWT token
  Future<String?> getToken() async {
    return _preferences.getString(_tokenKey);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    return _preferences.containsKey(_tokenKey);
  }

  /// Clear JWT token
  Future<bool> clearToken() async {
    return await _preferences.remove(_tokenKey);
  }

  /// Save user data
  Future<void> saveUserData({
    required int userId,
    required String email,
    required String name,
    required String role,
  }) async {
    await _preferences.setInt(_userIdKey, userId);
    await _preferences.setString(_userEmailKey, email);
    await _preferences.setString(_userNameKey, name);
    await _preferences.setString(_userRoleKey, role);
  }

  /// Get user ID
  int? getUserId() {
    return _preferences.getInt(_userIdKey);
  }

  /// Get user email
  String? getUserEmail() {
    return _preferences.getString(_userEmailKey);
  }

  /// Get user name
  String? getUserName() {
    return _preferences.getString(_userNameKey);
  }

  /// Get user role
  String? getUserRole() {
    return _preferences.getString(_userRoleKey);
  }

  /// Clear all user data
  Future<bool> clearAll() async {
    return await _preferences.clear();
  }
}
