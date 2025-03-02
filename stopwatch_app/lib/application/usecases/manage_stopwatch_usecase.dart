import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class ManageStopwatchUseCase {
  final UserRepository _repository;

  ManageStopwatchUseCase(this._repository);

  // 이 메서드는 이제 앱 초기화 이후에 호출된다고 가정
  // 상태를 가져오기만 하고 초기화는 하지 않음
  Future<UserState> getCurrentState(String userId) async {
    return await _repository.getUserState(userId);
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
