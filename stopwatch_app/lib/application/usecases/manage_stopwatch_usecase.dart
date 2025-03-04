import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

/// 스톱워치 관리 유즈케이스
/// 스톱워치 상태 조회, 시작, 정지, 시간 업데이트 등의 비즈니스 로직 캡슐화
class ManageStopwatchUseCase {
  final UserRepository _repository;

  ManageStopwatchUseCase(this._repository);

  /// 사용자 스톱워치 상태 조회
  /// 오류 발생시 (404 등) 새로운 기본 상태 반환
  Future<UserState> getCurrentState(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('유효하지 않은 사용자 ID');
    }
    
    try {
      return await _repository.getUserState(userId);
    } catch (e) {
      // 사용자 상태가 없을 경우 (404 등) 새로운 기본 상태 반환
      return UserState(
        userId: userId,
        online: true,
        stopwatchRunning: false,
        elapsedTime: 0,
      );
    }
  }

  /// 스톱워치 시작
  /// 이미 실행 중이면 현재 상태 유지
  Future<UserState> startStopwatch(UserState currentState) async {
    if (currentState.userId.isEmpty) {
      throw ArgumentError('유효하지 않은 사용자 상태');
    }
    
    // 이미 실행 중이면 상태 변경 없음
    if (currentState.stopwatchRunning) {
      return currentState;
    }
    
    try {
      // 스톱워치 시작 상태로 업데이트
      final updatedState = currentState.copyWith(
        stopwatchRunning: true,
        online: true,
      );
      
      // 서버에 상태 업데이트
      await _repository.updateUserState(updatedState);
      return updatedState;
    } catch (e) {
      // 오류 발생 시 원래 상태 반환
      return currentState;
    }
  }

  /// 스톱워치 정지
  /// 이미 정지 상태면 현재 상태 유지
  Future<UserState> stopStopwatch(UserState currentState) async {
    if (currentState.userId.isEmpty) {
      throw ArgumentError('유효하지 않은 사용자 상태');
    }
    
    // 이미 정지 상태면 상태 변경 없음
    if (!currentState.stopwatchRunning) {
      return currentState;
    }
    
    try {
      // 스톱워치 정지 상태로 업데이트
      final updatedState = currentState.copyWith(stopwatchRunning: false);
      
      // 서버에 상태 업데이트
      await _repository.updateUserState(updatedState);
      return updatedState;
    } catch (e) {
      // 오류 발생 시 원래 상태 반환
      return currentState;
    }
  }

  /// 경과 시간 업데이트 (1초 증가)
  /// 스톱워치가 실행 중일 때만 시간 업데이트
  Future<UserState> updateElapsedTime(UserState currentState) async {
    if (currentState.userId.isEmpty) {
      throw ArgumentError('유효하지 않은 사용자 상태');
    }
    
    // 스톱워치가 실행 중이 아니면 상태 변경 없음
    if (!currentState.stopwatchRunning) {
      return currentState;
    }
    
    try {
      // 시간 1초 증가
      final updatedState = currentState.copyWith(
        elapsedTime: currentState.elapsedTime + 1,
      );
      
      // 서버에 상태 업데이트
      await _repository.updateUserState(updatedState);
      return updatedState;
    } catch (e) {
      // 오류 발생 시 시간이 증가된 상태 반환 (UI 연속성 유지)
      return currentState.copyWith(
        elapsedTime: currentState.elapsedTime + 1,
      );
    }
  }
}
