import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _webBaseUrl = 'http://localhost:8000/api';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _localBaseUrl = 'http://127.0.0.1:8000/api';

  static String get developmentBaseUrl {
    if (kIsWeb) {
      return _webBaseUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidEmulatorBaseUrl;
      default:
        return _localBaseUrl;
    }
  }

  static const String productionBaseUrl = 'https://api.silappol.id/api';
  static const bool useProduction = bool.fromEnvironment(
    'SILAPPOL_USE_PRODUCTION_API',
    defaultValue: false,
  );
  static const String tokenStorageKey = 'silappol_sanctum_token';

  static String get baseUrl =>
      useProduction ? productionBaseUrl : developmentBaseUrl;
}

// NOTE: untuk testing di perangkat fisik, ganti manual developmentBaseUrl
// menjadi IP LAN laptop, misalnya http://192.168.x.x:8000/api.
