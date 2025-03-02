import 'dart:async';
import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class GetAllUsersUseCase {
  final UserRepository _repository;

  GetAllUsersUseCase(this._repository);

  Stream<UserState> getAllUserStates() {
    return _repository.getUserStateStream();
  }

  Future<List<UserState>> getAllInitialUserStates() async {
    // 서버에서 모든 사용자 상태를 가져오는 API 호출
    return await _repository.getAllUserStates();
  }
}
