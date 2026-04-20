import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Optional override:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
  static const _overrideBaseUrl = String.fromEnvironment("API_BASE_URL");

  // Android emulator => 10.0.2.2
  // iOS simulator / desktop => 127.0.0.1
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (kIsWeb) return "http://localhost:8080";
    if (Platform.isAndroid) return "http://10.0.2.2:8080";
    if (Platform.isIOS) return "http://127.0.0.1:8080";
    return "http://127.0.0.1:8080";
  }

  static const auth = "/auth";
  static const users = "/api/users";
}
