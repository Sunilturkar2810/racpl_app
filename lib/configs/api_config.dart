import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String productionBaseUrl = 'https://racpl-erp.vercel.app/api';
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return _normalize(configured);
    }
    return _normalize(_defaultLocalBaseUrl);
  }

  static String get _defaultLocalBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Use local IP address for real device over WiFi
       // return 'http://10.126.47.237:5000/api';
        return 'http://192.168.1.20:5000/api';
        
        
      default:
        return 'http://localhost:5000/api';
    }
  }

  static String _normalize(String value) {
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
