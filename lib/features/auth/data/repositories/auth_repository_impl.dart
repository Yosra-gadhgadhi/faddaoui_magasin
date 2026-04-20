// import 'package:elfaddoui_app/features/auth/data/datasources/auth_remote_datasource.dart.dart';

// import '../../../../core/storage/token_storage.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../models/login_request_model.dart';
// import '../models/register_request_model.dart';
// import '../models/forgot_password_request_model.dart';
// import '../models/reset_password_request_model.dart';

// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemoteDataSource remote;
//   final TokenStorage storage;

//   AuthRepositoryImpl({
//     required this.remote,
//     required this.storage,
//   });

//   @override
//   Future<String> signUp({
//     required String fullName,
//     required String email,
//     required String password,
//   }) async {
//     final res = await remote.register(
//       RegisterRequestModel(fullName: fullName, email: email, password: password),
//     );
//     await storage.saveToken(res.token);
//     return res.token;
//   }

//   @override
//   Future<String> signIn({required String email, required String password}) async {
//     final res = await remote.login(LoginRequestModel(email: email, password: password));
//     await storage.saveToken(res.token);
//     return res.token;
//   }

//   @override
//   Future<String> requestReset({required String email}) async {
//     return remote.forgotPassword(ForgotPasswordRequestModel(email: email));
//   }

//   @override
//   Future<void> resetPassword({required String resetToken, required String newPassword}) {
//     return remote.resetPassword(ResetPasswordRequestModel(resetToken: resetToken, newPassword: newPassword));
//   }

//   @override
//   Future<void> logout() => storage.clear();
// }
import 'package:elfaddoui_app/features/auth/data/datasources/auth_remote_datasource.dart.dart';

import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';

import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/reset_password_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage storage;

  AuthRepositoryImpl({
    required this.remote,
    required this.storage,
  });

  @override
  Future<String> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await remote.register(
      RegisterRequestModel(
        fullName: fullName,
        email: email,
        password: password,
      ),
    );

    return res.token;
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final res = await remote.login(
      LoginRequestModel(
        email: email,
        password: password,
      ),
    );

    await storage.saveToken(res.token);

    return res.token;
  }

  @override
  Future<String> requestReset({
    required String email,
  }) async {
    final token = await remote.forgotPassword(
      ForgotPasswordRequestModel(
        email: email,
      ),
    );

    return token;
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await remote.resetPassword(
      ResetPasswordRequestModel(
        resetToken: resetToken,
        newPassword: newPassword,
      ),
    );
  }

  @override
  Future<void> logout() async {
    await storage.clear();
  }
}
