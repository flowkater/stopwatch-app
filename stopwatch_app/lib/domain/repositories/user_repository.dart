import '../models/user_state.dart';

/// 사용자 데이터 저장소 인터페이스
/// 
/// 사용자 상태 관리 및 웹소켓 통신을 담당하는 레포지토리 인터페이스
abstract class UserRepository {
  /// 사용자 상태 업데이트
  Future<void> updateUserState(UserState userState);

  /// 사용자 상태 스트림 구독
  Stream<UserState> getUserStateStream();

  /// 특정 사용자 상태 조회
  Future<UserState> getUserState(String userId);

  /// 웹소켓 연결 종료
  Future<void> closeConnection();

  /// 웹소켓 연결 시작
  /// 선택적으로 사용자 ID를 받아 해당 사용자로 연결
  Future<void> connect({String? userId});
  
  /// 연결 상태 확인 및 필요시 재연결
  Future<bool> checkConnection();

  /// 특정 사용자의 상태 스트림 구독
  Stream<UserState> getUserStateStreamFor(String userId);

  /// 모든 사용자 상태 조회
  Future<List<UserState>> getAllUserStates();
}
