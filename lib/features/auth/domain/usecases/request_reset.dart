import '../repositories/auth_repository.dart';

class RequestReset {
  final AuthRepository repo;
  RequestReset(this.repo);

  Future<String> call({required String email}) {
    return repo.requestReset(email: email);
  }
}