import 'dart:async';
import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class GetAllUsersUseCase {
  final UserRepository _repository;

  GetAllUsersUseCase(this._repository);

  Stream<UserState> getAllUserStates() {
    return _repository.getUserStateStream();
  }
}
