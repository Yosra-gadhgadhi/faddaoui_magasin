// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/network/api_error_parser.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../../domain/usecases/sign_in.dart';
// import '../../domain/usecases/sign_up.dart';
// import '../../domain/usecases/request_reset.dart';
// import '../../domain/usecases/reset_password.dart';
// import 'auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   final SignIn signInUC;
//   final SignUp signUpUC;
//   final RequestReset requestResetUC;
//   final ResetPassword resetPasswordUC;
//   final AuthRepository repo;

//   AuthCubit({
//     required this.signInUC,
//     required this.signUpUC,
//     required this.requestResetUC,
//     required this.resetPasswordUC,
//     required this.repo,
//   }) : super(const AuthState());

//   Future<void> signIn(String email, String password) async {
//     try {
//       emit(state.copyWith(loading: true, error: null));
//       final token = await signInUC(email: email, password: password);
//       emit(state.copyWith(loading: false, token: token));
//     } catch (e) {
//       emit(state.copyWith(loading: false, error: parseApiError(e)));
//     }
//   }

//   Future<void> signUp(String fullName, String email, String password) async {
//     try {
//       emit(state.copyWith(loading: true, error: null));
//       final token = await signUpUC(fullName: fullName, email: email, password: password);
//       emit(state.copyWith(loading: false, token: token));
//     } catch (e) {
//       emit(state.copyWith(loading: false, error: parseApiError(e)));
//     }
//   }

//   Future<void> requestReset(String email) async {
//     try {
//       emit(state.copyWith(loading: true, error: null, passwordResetDone: false));
//       final token = await requestResetUC(email: email);
//       emit(state.copyWith(loading: false, resetToken: token, emailForReset: email));
//     } catch (e) {
//       emit(state.copyWith(loading: false, error: parseApiError(e)));
//     }
//   }

//   Future<void> resetPassword(String resetToken, String newPassword) async {
//     try {
//       emit(state.copyWith(loading: true, error: null));
//       await resetPasswordUC(resetToken: resetToken, newPassword: newPassword);
//       emit(state.copyWith(loading: false, passwordResetDone: true));
//     } catch (e) {
//       emit(state.copyWith(loading: false, error: parseApiError(e)));
//     }
//   }

//   Future<void> logout() async {
//     await repo.logout();
//     emit(const AuthState());
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_error_parser.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/request_reset.dart';
import '../../domain/usecases/reset_password.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn signInUC;
  final SignUp signUpUC;
  final RequestReset requestResetUC;
  final ResetPassword resetPasswordUC;
  final AuthRepository repo;

  AuthCubit({
    required this.signInUC,
    required this.signUpUC,
    required this.requestResetUC,
    required this.resetPasswordUC,
    required this.repo,
  }) : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    try {
      emit(state.copyWith(loading: true, error: null));

      final token = await signInUC(
        email: email,
        password: password,
      );

      emit(state.copyWith(
        loading: false,
        token: token,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: parseApiError(e),
      ));
    }
  }

  Future<void> signUp(String fullName, String email, String password) async {
    try {
      emit(state.copyWith(loading: true, error: null));

      final token = await signUpUC(
        fullName: fullName,
        email: email,
        password: password,
      );

      emit(state.copyWith(
        loading: false,
        token: token,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: parseApiError(e),
      ));
    }
  }

  Future<void> requestReset(String email) async {
    try {
      emit(state.copyWith(
        loading: true,
        error: null,
        passwordResetDone: false,
      ));

      final token = await requestResetUC(email: email);

      emit(state.copyWith(
        loading: false,
        resetToken: token,
        emailForReset: email,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: parseApiError(e),
      ));
    }
  }

  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      emit(state.copyWith(
        loading: true,
        error: null,
      ));

      await resetPasswordUC(
        resetToken: resetToken,
        newPassword: newPassword,
      );

      emit(state.copyWith(
        loading: false,
        passwordResetDone: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: parseApiError(e),
      ));
    }
  }

  Future<void> logout() async {
    await repo.logout();
    emit(const AuthState());
  }
}