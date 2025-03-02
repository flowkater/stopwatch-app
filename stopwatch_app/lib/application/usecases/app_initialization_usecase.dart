import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class AppInitializationUseCase {
  final UserRepository _repository;

  AppInitializationUseCase(this._repository); // 선택적 Ref 매개변수

  /// 앱 초기화 - 로그인 시 한 번만 호출
  Future<UserState> initializeApp(String userId) async {
    print('앱 초기화 시작');
    // 1. 웹소켓 연결 시작
    await _repository.connect();

    // 2. 사용자 상태 초기화 또는 가져오기
    UserState userState = await _repository.getUserState(userId).onError((
      error,
      stackTrace,
    ) {
      return UserState(
        userId: userId,
        online: true,
        stopwatchRunning: false,
        elapsedTime: 0,
      );
    });

    // 3. 온라인 상태로 업데이트
    if (!userState.online) {
      userState = userState.copyWith(online: true);
    }

    // 4. 상태 업데이트
    await _repository.updateUserState(userState);

    return userState;
  }
}
