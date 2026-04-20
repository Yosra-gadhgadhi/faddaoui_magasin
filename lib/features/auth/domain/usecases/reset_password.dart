import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repo;
  ResetPassword(this.repo);

  Future<void> call({required String resetToken, required String newPassword}) {
    return repo.resetPassword(resetToken: resetToken, newPassword: newPassword);
  }
}