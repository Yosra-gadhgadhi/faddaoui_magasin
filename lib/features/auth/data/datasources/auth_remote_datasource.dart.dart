import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/network/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/reset_password_request_model.dart';

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  Future<AuthResponseModel> register(RegisterRequestModel req) async {
    final r = await dio.post(
      "${ApiConstants.auth}/register",
      data: req.toAuthJson(),
    );
    _throwIfHttpError(r, "register");
    return AuthResponseModel.fromJson(
      _asMap(r.data, "register"),
      allowMessageFallback: true,
    );
  }

  Future<AuthResponseModel> login(LoginRequestModel req) async {
    final r = await dio.post("${ApiConstants.auth}/login", data: req.toJson());
    _throwIfHttpError(r, "login");
    return AuthResponseModel.fromJson(_asMap(r.data, "login"));
  }

  // backend returns String token (testing)
  Future<String> forgotPassword(ForgotPasswordRequestModel req) async {
    final r = await dio.post(
      "${ApiConstants.auth}/forgot-password",
      data: req.toJson(),
      // Some backends return raw token text, not strict JSON.
      options: Options(responseType: ResponseType.plain),
    );
    _throwIfHttpError(r, "forgot-password");
    return _extractForgotToken(r.data);
  }

  Future<void> resetPassword(ResetPasswordRequestModel req) async {
    final r = await dio.post("${ApiConstants.auth}/reset-password",
        data: req.toJson());
    _throwIfHttpError(r, "reset-password");
  }

  void _throwIfHttpError(Response<dynamic> r, String route) {
    final status = r.statusCode ?? 0;
    if (status >= 400) {
      throw DioException(
        requestOptions: r.requestOptions,
        response: r,
        type: DioExceptionType.badResponse,
        message: "HTTP $status on $route",
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic data, String route) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw FormatException("Réponse invalide pour $route.");
  }

  String _extractForgotToken(dynamic data) {
    if (data == null) return "";

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return "";

      // Case 1: raw token text
      if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {
        return trimmed.replaceAll('"', '');
      }

      // Case 2: JSON string body
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return _tokenFromMap(decoded);
      }
      if (decoded is Map) {
        return _tokenFromMap(Map<String, dynamic>.from(decoded));
      }
      return trimmed.replaceAll('"', '');
    }

    if (data is Map<String, dynamic>) return _tokenFromMap(data);
    if (data is Map) return _tokenFromMap(Map<String, dynamic>.from(data));

    return data.toString();
  }

  String _tokenFromMap(Map<String, dynamic> map) {
    final v1 = map["resetToken"];
    if (v1 is String && v1.isNotEmpty) return v1;
    final v2 = map["token"];
    if (v2 is String && v2.isNotEmpty) return v2;
    final v3 = map["message"];
    if (v3 is String && v3.isNotEmpty) return v3;
    return map.toString();
  }
}
