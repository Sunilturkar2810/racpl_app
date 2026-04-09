import '../configs/api_config.dart';

class AppConstants {
  // Backend API
  static String get apiBaseUrl => ApiConfig.baseUrl;
  static const String apiTimeout = '30 seconds';

  // Roles
  static const String roleEmployee = 'Employee';
  static const String roleManager = 'Manager';
  static const String roleAdmin = 'Admin';

  // Themes
  static const String themeLight = 'light';
  static const String themeDark = 'dark';

  // Common values
  static const String defaultDepartment = 'IT';
  static const String defaultDesignation = 'Software Engineer';
}
