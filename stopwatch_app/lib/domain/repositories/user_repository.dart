import '../models/user_state.dart';

abstract class UserRepository {
  // 사용자 상태 업데이트
  Future<void> updateUserState(UserState userState);

  // 사용자 상태 스트림 구독
  Stream<UserState> getUserStateStream();

  // 연결 종료
  Future<void> closeConnection();

  // 연결 시작
  Future<void> connect();

  // 특정 사용자의 상태 스트림 구독
  Stream<UserState> getUserStateStreamFor(String userId);
}
