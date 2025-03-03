import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class ManageStopwatchUseCase {
  final UserRepository _repository;

  ManageStopwatchUseCase(this._repository);

  // 사용자 상태를 가져오되, 404 오류 시 새 상태 생성
  Future<UserState> getCurrentState(String userId) async {
    try {
      return await _repository.getUserState(userId);
    } catch (e) {
      // 사용자 상태가 없을 경우 (404 등) 새로운의 기본 상태 반환
      print('사용자 상태를 가져오는 중 오류 발생: $e, 새 상태 생성');
      return UserState(
        userId: userId,
        online: true,
        stopwatchRunning: false,
        elapsedTime: 0,
      );
    }
  }

  Future<UserState> startStopwatch(UserState currentState) async {
    if (!currentState.stopwatchRunning) {
      final updatedState = currentState.copyWith(
        stopwatchRunning: true,
        online: true,
      );
      await _repository.updateUserState(updatedState);
      return updatedState;
    }
    return currentState;
  }

  Future<UserState> stopStopwatch(UserState currentState) async {
    if (currentState.stopwatchRunning) {
      final updatedState = currentState.copyWith(stopwatchRunning: false);
      await _repository.updateUserState(updatedState);
      return updatedState;
    }
    return currentState;
  }

  Future<UserState> updateElapsedTime(UserState currentState) async {
    if (currentState.stopwatchRunning) {
      final updatedState = currentState.copyWith(
        elapsedTime: currentState.elapsedTime + 1,
      );
      await _repository.updateUserState(updatedState);
      return updatedState;
    }
    return currentState;
  }
}
