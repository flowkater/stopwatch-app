import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/user_state.dart';
import '../config/user_id_provider.dart';
import '../usercase/usecase_providers.dart';

// 내 스톱워치 상태 프로바이더
final myStopwatchProvider =
    StateNotifierProvider<MyStopwatchNotifier, AsyncValue<UserState>>((ref) {
      return MyStopwatchNotifier(ref);
    });

class MyStopwatchNotifier extends StateNotifier<AsyncValue<UserState>> {
  final Ref _ref;
  Timer? _timer;

  MyStopwatchNotifier(this._ref) : super(const AsyncLoading()) {
    _init();
  }

  void _init() async {
    final myUserId = _ref.read(myUserIdProvider);
    final stopwatchUseCase = _ref.read(manageStopwatchUseCaseProvider);

    try {
      // 초기 상태 설정
      final initialState = await stopwatchUseCase.initializeStopwatch(myUserId);
      state = AsyncData(initialState);

      // 타이머 설정
      _setupTimer();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
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
    super.dispose();
  }
}
