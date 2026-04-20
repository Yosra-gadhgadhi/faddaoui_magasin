import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repo;
  SignUp(this.repo);

  Future<String> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    return repo.signUp(fullName: fullName, email: email, password: password);
  }
}