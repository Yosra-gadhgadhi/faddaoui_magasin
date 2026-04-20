// import 'package:dio/dio.dart';
// import '../storage/token_storage.dart';
// import 'api_constants.dart';

// class DioClient {
//   final Dio dio;

//   DioClient(TokenStorage storage)
//       : dio = Dio(
//           BaseOptions(
//             baseUrl: ApiConstants.baseUrl,
//             connectTimeout: const Duration(seconds: 15),
//             receiveTimeout: const Duration(seconds: 15),
//             headers: {"Content-Type": "application/json"},
//           ),
//         ) {
//     // ✅ Print everything (VERY helpful)
//     dio.interceptors.add(
//       LogInterceptor(
//         request: true,
//         requestHeader: true,
//         requestBody: true,
//         responseHeader: true,
//         responseBody: true,
//         error: true,
//       ),
//     );

//     // ✅ Add JWT automatically
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final token = await storage.readToken();
//           if (token != null && token.isNotEmpty) {
//             options.headers["Authorization"] = "Bearer $token";
//           }
//           handler.next(options);
//         },
//       ),
//     );
//   }
// }

import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_constants.dart';

class DioClient {
  final Dio dio;

  DioClient(TokenStorage storage)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {"Content-Type": "application/json"},
            // ✅ IMPORTANT: ne pas throw automatiquement sur 401/400
            validateStatus: (code) => code != null && code >= 200 && code < 500,
          ),
        ) {
    // ✅ Logs complets
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    // ✅ Interceptor JWT
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // options.path = "/api/auth/forgot-password" (souvent)
          final path = options.path;

          final isAuthRoute = path.startsWith(ApiConstants.auth); // "/api/auth"

          if (isAuthRoute) {
            // ✅ très important: ne jamais envoyer Authorization pour /api/auth/**
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
        onError: (e, handler) {
          handler.next(e);
        },
      ),
    );
  }
}