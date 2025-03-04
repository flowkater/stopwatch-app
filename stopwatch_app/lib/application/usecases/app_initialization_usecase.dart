import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class AppInitializationUseCase {
  final UserRepository _repository;
  bool _isInitialized = false;

  AppInitializationUseCase(this._repository);

  /// 앱 초기화 - 로그인 시 한 번만 호출
  Future<UserState> initializeApp(String userId) async {
    print('앱 초기화 시작: userId=$userId, isInitialized=$_isInitialized');
    
    if (userId.isEmpty) {
      throw Exception('사용자 ID가 비어있습니다.');
    }
    
    // 1. 웹소켓 연결 시작 (기존 연결 종료 후)
    try {
      await _repository.closeConnection(); // 기존 연결 종료
      await _repository.connect(userId: userId); // userId와 함께 연결
      _isInitialized = true;
    } catch (e) {
      print('웹소켓 연결 오류: $e');
      _isInitialized = false;
      rethrow;
    }

    // 2. 사용자 상태 초기화 또는 가져오기
    UserState userState;
    try {
      userState = await _repository.getUserState(userId);
    } catch (e) {
      print('사용자 상태 가져오기 오류: $e, 새 상태 생성');
      // 기본 상태 생성
      userState = UserState(
        userId: userId,
        online: true,
        stopwatchRunning: false,
        elapsedTime: 0,
      );
    }

    // 3. 온라인 상태로 업데이트
    userState = userState.copyWith(online: true);

    // 4. 상태 업데이트
    try {
      await _repository.updateUserState(userState);
      print('사용자 상태 업데이트 완료: ${userState.toJson()}');
    } catch (e) {
      print('사용자 상태 업데이트 오류: $e');
    }

    return userState;
  }
  
  /// 앱 정리 - 로그아웃 시 호출
  Future<void> cleanupApp() async {
    print('앱 정리 시작');
    
    if (_isInitialized) {
      try {
        await _repository.closeConnection();
        _isInitialized = false;
        print('앱 정리 완료');
      } catch (e) {
        print('앱 정리 오류: $e');
      }
    } else {
      print('이미 정리되었거나 초기화되지 않은 상태');
    }
  }
}
