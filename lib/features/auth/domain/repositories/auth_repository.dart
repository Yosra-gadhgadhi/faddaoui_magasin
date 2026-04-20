abstract class AuthRepository {
  Future<String> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<String> signIn({
    required String email,
    required String password,
  });


  Future<String> requestReset({required String email});

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  Future<void> logout();
}