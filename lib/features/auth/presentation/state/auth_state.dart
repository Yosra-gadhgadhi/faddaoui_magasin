import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool loading;
  final String? token;
  final String? resetToken;
  final String? emailForReset;
  final bool passwordResetDone;
  final String? error;

  const AuthState({
    this.loading = false,
    this.token,
    this.resetToken,
    this.emailForReset,
    this.passwordResetDone = false,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    String? token,
    String? resetToken,
    String? emailForReset,
    bool? passwordResetDone,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      token: token ?? this.token,
      resetToken: resetToken ?? this.resetToken,
      emailForReset: emailForReset ?? this.emailForReset,
      passwordResetDone: passwordResetDone ?? this.passwordResetDone,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, token, resetToken, emailForReset, passwordResetDone, error];
}