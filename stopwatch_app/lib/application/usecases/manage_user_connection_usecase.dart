import '../../domain/repositories/user_repository.dart';

class ManageUserConnectionUseCase {
  final UserRepository _repository;

  ManageUserConnectionUseCase(this._repository);

  Future<void> connect() async {
    await _repository.connect();
  }

  Future<void> disconnect() async {
    await _repository.closeConnection();
  }
}
