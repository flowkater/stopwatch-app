import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class ManageStopwatchUseCase {
  final UserRepository _repository;

  ManageStopwatchUseCase(this._repository);

  Future<UserState> initializeStopwatch(String userId) async {
    final initialState = UserState(
      userId: userId,
      online: true,
      stopwatchRunning: false,
      elapsedTime: 0,
    );

    await _repository.updateUserState(initialState);
    return initialState;
  }

  Future<UserState> startStopwatch(UserState currentState) async {
    if (!currentState.stopwatchRunning) {
      final updatedState = currentState.copyWith(stopwatchRunning: true);
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
