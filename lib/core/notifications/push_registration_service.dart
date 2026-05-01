import 'dart:io';

import 'package:dio/dio.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushRegistrationService {
  PushRegistrationService(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  bool _initialized = false;

  Future<void> initAndRegister() async {
    try {
      if (!_initialized) {
        final ready = await _initFirebaseSafe();
        if (!ready) return;
        _initialized = true;
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          registerDeviceToken(token: token);
        });
      }
      await _requestPermissionIfNeeded();
      final token = await _getMessagingTokenSafe();
      if (token == null || token.trim().isEmpty) return;
      await registerDeviceToken(token: token);
    } catch (_) {
      // Best effort; never crash app startup on push setup.
    }
  }

  Future<bool> _initFirebaseSafe() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _requestPermissionIfNeeded() async {
    if (kIsWeb) return;
    if (Platform.isIOS || Platform.isMacOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<String?> _getMessagingTokenSafe() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      // On Apple platforms APNs token may not be ready immediately,
      // especially on simulator where remote push is unavailable.
      String? apnsToken;
      for (var i = 0; i < 3; i++) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      if (apnsToken == null || apnsToken.isEmpty) return null;
    }
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> registerDeviceToken({required String token}) async {
    final jwt = await _storage.readToken();
    if (jwt == null || jwt.isEmpty) return;

    final platform = kIsWeb
        ? 'web'
        : Platform.isIOS
            ? 'ios'
            : Platform.isAndroid
                ? 'android'
                : 'other';

    try {
      await _dio.post(
        '/api/notifications/device-token',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          validateStatus: (code) => code != null && code < 500,
        ),
        data: {
          'token': token,
          'platform': platform,
        },
      );
    } catch (_) {
      // Best effort; keep app flow unaffected.
    }
  }
}
