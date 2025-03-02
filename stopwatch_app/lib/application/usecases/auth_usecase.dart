import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch_app/application/providers/providers.dart';

import '../../domain/repositories/user_repository.dart';
import 'app_initialization_usecase.dart';

class AuthUseCase {
  final UserRepository _repository;
  final AppInitializationUseCase _initUseCase;
  final Ref? _ref;

  AuthUseCase(this._repository, this._initUseCase, this._ref);

  /// 사용자 로그인 처리
  Future<void> login(String userId) async {
    try {
      // 앱 초기화 (연결 및 상태 초기화 포함)
      await _initUseCase.initializeApp(userId);

      // SharedPreferences에 사용자 ID 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
    } catch (e) {
      print('로그인 오류: $e');
      rethrow;
    }
  }

  /// 사용자 로그아웃 처리
  Future<void> logout(String userId) async {
    try {
      // 현재 상태 가져오기
      final currentState = await _repository.getUserState(userId);
      await _ref?.read(myStopwatchProvider.notifier).stopStopwatch();
      print('stopwatch 정지');

      // 오프라인 상태로 업데이트
      final updatedState = currentState.copyWith(
        stopwatchRunning: false,
        online: false,
      );
      await _repository.updateUserState(updatedState);

      // 연결 종료
      await _repository.closeConnection();

      await Future.delayed(const Duration(milliseconds: 500));

      print('연결 종료');
      // SharedPreferences에서 사용자 ID 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      print('사용자 ID 삭제');
      print('로그아웃 완료');
    } catch (e) {
      // 에러가 발생해도 SharedPreferences는 삭제 시도
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      print('사용자 ID 삭제');
      print('서버 로그아웃 에러 완료');
      rethrow;
    }
  }
}
