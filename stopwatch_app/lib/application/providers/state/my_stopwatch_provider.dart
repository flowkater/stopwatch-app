import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/user_state.dart';
import '../config/user_id_provider.dart';
import '../service/user_repository_provider.dart';
import '../usercase/usecase_providers.dart';

/// 내 스톱워치 상태를 관리하는 프로바이더
/// 내 사용자 ID에 따라 자동으로 초기화되고, 자동 소멸(autoDispose) 지원
final myStopwatchProvider = StateNotifierProvider.autoDispose<
  MyStopwatchNotifier,
  AsyncValue<UserState>
>((ref) {
  final userId = ref.watch(myUserIdProvider);
  
  // 인스턴스 유지 설정 (autoDispose와 함께 사용)
  ref.keepAlive();
  
  // 인증 상태에 따른 처리
  final isAuthenticated = userId.isNotEmpty;
  
  return MyStopwatchNotifier(ref, isAuthenticated: isAuthenticated);
});

/// 내 스톱워치 상태 관리 StateNotifier
/// - 타이머 기반 주기적 업데이트
/// - 스톱워치 시작/정지 기능
/// - 인증 상태에 따른 초기화
class MyStopwatchNotifier extends StateNotifier<AsyncValue<UserState>> {
  final Ref _ref;
  final bool _isAuthenticated;
  Timer? _timer;

  MyStopwatchNotifier(this._ref, {required bool isAuthenticated}) 
      : _isAuthenticated = isAuthenticated,
        super(const AsyncLoading()) {
    if (_isAuthenticated) {
      _initializeStopwatchState();
    } else {
      state = const AsyncData(UserState(
        userId: '',
        online: false,
        stopwatchRunning: false,
        elapsedTime: 0,
      ));
    }
  }

  /// 스톱워치 상태 초기화
  Future<void> _initializeStopwatchState() async {
    if (!_isAuthenticated) {
      return;
    }

    final myUserId = _ref.read(myUserIdProvider);
    final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);

    try {
      // 사용자 상태 가져오기 (유즈케이스에서 실패 시 기본 상태 생성)
      final currentState = await stopwatchUseCase.getCurrentState(myUserId);
      
      // 사용자가 온라인 상태가 아니면 온라인으로 업데이트
      final updatedState = currentState.online 
          ? currentState 
          : currentState.copyWith(online: true);
      
      // 온라인 상태 업데이트가 필요한 경우
      if (!currentState.online) {
        await _ref.read(userRepositoryProvider).updateUserState(updatedState);
      }
      
      // 상태 업데이트
      state = AsyncData(updatedState);
      
      // 주기적 업데이트 타이머 설정
      _setupPeriodicTimer();
    } catch (e) {
      // 오류 발생 시 기본 상태로 초기화
      final defaultState = UserState(
        userId: myUserId,
        online: true,
        stopwatchRunning: false,
        elapsedTime: 0,
      );
      state = AsyncData(defaultState);
      _setupPeriodicTimer();
    }
  }

  /// 주기적 시간 업데이트를 위한 타이머 설정
  void _setupPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (state is AsyncData) {
        final currentState = (state as AsyncData<UserState>).value;
        
        // 스톱워치가 실행 중인 경우만 시간 업데이트
        if (currentState.stopwatchRunning) {
          final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);
          try {
            final updatedState = await stopwatchUseCase.updateElapsedTime(
              currentState,
            );
            if (mounted) {
              state = AsyncData(updatedState);
            }
          } catch (e) {
            // 시간 업데이트 실패 시 UI에 영향 없이 계속 진행
          }
        }
      }
    });
  }

  /// 스톱워치 시작
  /// 현재 상태에서 스톱워치 실행 상태로 변경
  Future<void> startStopwatch() async {
    if (state is! AsyncData) return;
    
    try {
      final currentState = (state as AsyncData<UserState>).value;
      final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);
      final updatedState = await stopwatchUseCase.startStopwatch(currentState);
      
      if (mounted) {
        state = AsyncData(updatedState);
      }
    } catch (e) {
      // 오류 발생 시 상태 변경 없음
    }
  }

  /// 스톱워치 정지
  /// 현재 상태에서 스톱워치 중지 상태로 변경
  Future<void> stopStopwatch() async {
    if (state is! AsyncData) return;
    
    try {
      final currentState = (state as AsyncData<UserState>).value;
      final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);
      final updatedState = await stopwatchUseCase.stopStopwatch(currentState);
      
      if (mounted) {
        state = AsyncData(updatedState);
      }
    } catch (e) {
      // 오류 발생 시 상태 변경 없음
    }
  }

  /// 리소스 정리
  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }
  
  /// 타이머 정리
  void _cleanupResources() {
    _timer?.cancel();
    _timer = null;
  }
}
