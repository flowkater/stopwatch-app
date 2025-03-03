import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/user_state.dart';
import '../config/user_id_provider.dart';
import '../service/user_repository_provider.dart';
import '../usercase/usecase_providers.dart';

// 내 스톱워치 상태 프로바이더
final myStopwatchProvider =
    StateNotifierProvider.autoDispose<MyStopwatchNotifier, AsyncValue<UserState>>((ref) {
      final userId = ref.watch(myUserIdProvider);
      
      // userId 변경 시 provider 재생성을 위한 종속성 설정
      ref.keepAlive();
      
      // userId가 비어있으면 로딩 상태 유지
      if (userId.isEmpty) {
        return MyStopwatchNotifier(ref, isInitialized: false);
      }
      return MyStopwatchNotifier(ref, isInitialized: true);
    });

class MyStopwatchNotifier extends StateNotifier<AsyncValue<UserState>> {
  final Ref _ref;
  Timer? _timer;
  final bool _isInitialized;

  MyStopwatchNotifier(this._ref, {required bool isInitialized}) 
      : _isInitialized = isInitialized,
        super(const AsyncLoading()) {
    if (_isInitialized) {
      _init();
    }
  }

  void setLoading() {
    state = const AsyncLoading();
  }

  void _init() async {
    final myUserId = _ref.read(myUserIdProvider);

    if (myUserId.isEmpty) {
      state = const AsyncLoading();
      return;
    }

    final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);

    try {
      // 사용자 상태 가져오기 (실패 시 기본 상태 생성)
      final currentState = await stopwatchUseCase.getCurrentState(myUserId);
      
      // 사용자가 온라인 상태가 아니면 온라인으로 업데이트
      final updatedState = currentState.online 
          ? currentState 
          : currentState.copyWith(online: true);
      
      // 상태 업데이트가 필요한 경우
      if (!currentState.online) {
        await _ref.read(userRepositoryProvider).updateUserState(updatedState);
      }
      
      state = AsyncData(updatedState);
      
      // 타이머 설정
      _setupTimer();
    } catch (e) {
      print('stopwatch 초기화 오류: $e');
      // 기본 상태로 복구 (에러 상태 대신)
      final defaultState = UserState(
        userId: myUserId,
        online: true,
        stopwatchRunning: false,
        elapsedTime: 0,
      );
      state = AsyncData(defaultState);
      _setupTimer();
    }
  }

  void _setupTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (state is AsyncData) {
        final currentState = (state as AsyncData<UserState>).value;
        if (currentState.stopwatchRunning) {
          final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);
          final updatedState = await stopwatchUseCase.updateElapsedTime(
            currentState,
          );
          state = AsyncData(updatedState);
        }
      }
    });
  }

  // 스톱워치 시작
  Future<void> startStopwatch() async {
    if (state is AsyncData) {
      final currentState = (state as AsyncData<UserState>).value;
      final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);
      final updatedState = await stopwatchUseCase.startStopwatch(currentState);
      state = AsyncData(updatedState);
    }
  }

  // 스톱워치 정지
  Future<void> stopStopwatch() async {
    if (state is AsyncData) {
      final currentState = (state as AsyncData<UserState>).value;
      final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);
      final updatedState = await stopwatchUseCase.stopStopwatch(currentState);
      state = AsyncData(updatedState);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
