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
    final candidates = <String>[
      "${ApiConstants.auth}/register",
      "${ApiConstants.auth}/signup",
      "${ApiConstants.auth}/sign-up",
      "${ApiConstants.users}/register",
      "/auth/register",
      "/auth/signup",
      "/auth/sign-up",
      "/api/v1/auth/register",
      "/api/v1/auth/signup",
      "/api/v1/auth/sign-up",
    ];

    Response<dynamic>? last;
    for (final path in candidates) {
      final payload =
          path.startsWith("/auth/") ? req.toAuthJson() : req.toLegacyJson();
      final r = await dio.post(path, data: payload);
      final status = r.statusCode ?? 0;
      if (status < 400) {
        return AuthResponseModel.fromJson(_asMap(r.data, "register"));
      }
      last = r;
      if (status != 404) {
        _throwIfHttpError(r, "register");
      }
    }

    if (last != null) {
      throw DioException(
        requestOptions: last.requestOptions,
        response: last,
        type: DioExceptionType.badResponse,
        message:
            "Aucune route d'inscription trouvée (testées: ${candidates.join(", ")})",
      );
    }
    throw const FormatException("Réponse invalide pour register.");
  }

  Future<AuthResponseModel> login(LoginRequestModel req) async {
    final r = await dio.post("${ApiConstants.auth}/login", data: req.toJson());
    _throwIfHttpError(r, "login");
    return AuthResponseModel.fromJson(_asMap(r.data, "login"));
  }

  // backend returns String token (testing)
  Future<String> forgotPassword(ForgotPasswordRequestModel req) async {
    final r = await dio.post("${ApiConstants.auth}/forgot-password",
        data: req.toJson());
    _throwIfHttpError(r, "forgot-password");
    return (r.data ?? "").toString();
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
}
