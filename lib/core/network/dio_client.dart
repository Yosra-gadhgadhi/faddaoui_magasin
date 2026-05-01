import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';
import 'api_constants.dart';

class DioClient {
  final Dio dio;

  static String _redactSensitive(String input) {
    var out = input;
    out = out.replaceAllMapped(
      RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      (_) => 'Bearer ***',
    );
    out = out.replaceAllMapped(
      RegExp(r'("token"\s*:\s*")([^"]+)(")', caseSensitive: false),
      (m) => '${m[1]}***${m[3]}',
    );
    out = out.replaceAllMapped(
      RegExp(r'(token\s*:\s*)([^\s,}]+)', caseSensitive: false),
      (m) => '${m[1]}***',
    );
    out = out.replaceAllMapped(
      RegExp(r'("password"\s*:\s*")([^"]+)(")', caseSensitive: false),
      (m) => '${m[1]}***${m[3]}',
    );
    out = out.replaceAllMapped(
      RegExp(r'(password\s*:\s*)([^\s,}]+)', caseSensitive: false),
      (m) => '${m[1]}***',
    );
    return out;
  }

  DioClient(TokenStorage storage)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {"Content-Type": "application/json"},
            // ✅ IMPORTANT: ne pas throw automatiquement sur 401/400
            validateStatus: (code) => code != null && code >= 200 && code < 500,
          ),
        ) {
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(_redactSensitive(obj.toString())),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          final isAuthRoute = path.startsWith(ApiConstants.auth);

          if (isAuthRoute) {
            options.headers.remove("Authorization");
          } else {
            final token = await storage.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            } else {
              options.headers.remove("Authorization");
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) async {
          final path = response.requestOptions.path;
          final isAuthRoute = path.startsWith(ApiConstants.auth);
          final status = response.statusCode ?? 0;
          if (!isAuthRoute && (status == 401 || status == 403)) {
            await storage.clear();
          }
          handler.next(response);
        },
        onError: (e, handler) async {
          final path = e.requestOptions.path;
          final isAuthRoute = path.startsWith(ApiConstants.auth);
          final status = e.response?.statusCode ?? 0;
          if (!isAuthRoute && (status == 401 || status == 403)) {
            await storage.clear();
          }
          handler.next(e);
        },
      ),
    );
  }
}
