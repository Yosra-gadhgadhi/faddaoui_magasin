// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class TokenStorage {
//   static const _kToken = "auth_token";
//   final FlutterSecureStorage _s = const FlutterSecureStorage();

//   Future<void> saveToken(String token) => _s.write(key: _kToken, value: token);
//   Future<String?> readToken() => _s.read(key: _kToken);
//   Future<void> clear() => _s.delete(key: _kToken);
// }

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kToken = "auth_token";
  static const _kBiometricEnabled = "biometric_enabled";
  static const _kBiometricEmail = "biometric_email";
  static const _kBiometricPassword = "biometric_password";
  static const _kOnboardingSeen = "onboarding_seen";
  final FlutterSecureStorage _s = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _s.write(key: _kToken, value: token);
  Future<String?> readToken() => _s.read(key: _kToken);
  Future<void> clear() => _s.delete(key: _kToken);

  Future<void> setBiometricEnabled(bool value) =>
      _s.write(key: _kBiometricEnabled, value: value ? '1' : '0');

  Future<bool> isBiometricEnabled() async {
    final raw = await _s.read(key: _kBiometricEnabled);
    return raw == '1';
  }

  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await _s.write(key: _kBiometricEmail, value: email);
    await _s.write(key: _kBiometricPassword, value: password);
  }

  Future<String?> readBiometricEmail() => _s.read(key: _kBiometricEmail);
  Future<String?> readBiometricPassword() => _s.read(key: _kBiometricPassword);

  Future<void> clearBiometricCredentials() async {
    await _s.delete(key: _kBiometricEmail);
    await _s.delete(key: _kBiometricPassword);
    await _s.delete(key: _kBiometricEnabled);
  }

  Future<void> setOnboardingSeen(bool value) =>
      _s.write(key: _kOnboardingSeen, value: value ? '1' : '0');

  Future<bool> hasSeenOnboarding() async {
    final raw = await _s.read(key: _kOnboardingSeen);
    return raw == '1';
  }
}
