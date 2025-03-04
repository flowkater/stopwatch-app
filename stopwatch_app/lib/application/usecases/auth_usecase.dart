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
    if (userId.isEmpty) {
      print('로그아웃: 사용자 ID가 비어있음');
      return;
    }
    
    print('로그아웃 시작: userId=$userId');
    
    try {
      // 1. 먼저 스톱워치 정지
      if (_ref != null) {
        try {
          await _ref.read(myStopwatchProvider.notifier).stopStopwatch();
          print('스톱워치 정지 완료');
        } catch (e) {
          print('스톱워치 정지 오류: $e');
        }
      }

      // 2. 사용자 상태 업데이트 (오프라인)
      try {
        final currentState = await _repository.getUserState(userId);
        final updatedState = currentState.copyWith(
          stopwatchRunning: false,
          online: false,
        );
        await _repository.updateUserState(updatedState);
        print('사용자 상태 오프라인으로 업데이트 완료');
      } catch (e) {
        print('사용자 상태 업데이트 오류: $e');
      }

      // 3. 앱 정리 (웹소켓 연결 종료)
      await _initUseCase.cleanupApp();
      
      // 4. SharedPreferences에서 사용자 ID 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      print('사용자 ID 삭제 완료');
      
      // 5. 로그아웃 처리 대기
      await Future.delayed(const Duration(milliseconds: 300));
      print('로그아웃 완료');
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
      
      // 오류가 발생해도 SharedPreferences는 삭제
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('userId');
        print('사용자 ID 삭제 완료 (오류 발생 후)');
      } catch (e) {
        print('사용자 ID 삭제 오류: $e');
      }
      
      // 앱 정리 한번 더 시도
      try {
        await _initUseCase.cleanupApp();
      } catch (e) {
        print('앱 정리 오류 (오류 발생 후): $e');
      }
      
      rethrow;
    }
  }
}
