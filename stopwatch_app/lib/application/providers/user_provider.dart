import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';
import '../../infrastructure/repositories/websocket_user_repository.dart';

const kWebSocketServerUrl =
    'wss://stopwatch-server-quiet-cherry-718.fly.dev/ws';

// 사용자 ID 프로바이더 (StateProvider로 변경 가능하도록)
final userIdProvider = StateProvider<String>((ref) => '');

// 내 사용자 ID 프로바이더 (기존 myUserIdProvider 대체)
final myUserIdProvider = Provider<String>((ref) {
  return ref.watch(userIdProvider);
});

// 웹소켓 레포지토리 프로바이더
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final repository = WebSocketUserRepository(serverUrl: kWebSocketServerUrl);

  // 연결 시작
  repository.connect();

  // 프로바이더가 dispose될 때 연결 종료
  ref.onDispose(() {
    repository.closeConnection();
  });

  return repository;
});

// 모든 사용자 상태 프로바이더
final allUsersProvider =
    StateNotifierProvider<AllUsersNotifier, AsyncValue<Map<String, UserState>>>(
      (ref) {
        return AllUsersNotifier(ref);
      },
    );

class AllUsersNotifier
    extends StateNotifier<AsyncValue<Map<String, UserState>>> {
  final Ref _ref;
  final _userMap = <String, UserState>{};
  StreamSubscription<UserState>? _subscription;

  AllUsersNotifier(this._ref) : super(const AsyncLoading()) {
    _init();
  }

  void _init() {
    final repository = _ref.read(userRepositoryProvider);

    // 새로운 구독 시작
    _subscription = repository.getUserStateStream().listen((userState) {
      _userMap[userState.userId] = userState;
      state = AsyncData(_userMap);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// 내 스톱워치 상태 프로바이더
final myStopwatchProvider =
    StateNotifierProvider<MyStopwatchNotifier, AsyncValue<UserState>>((ref) {
      return MyStopwatchNotifier(ref);
    });

class MyStopwatchNotifier extends StateNotifier<AsyncValue<UserState>> {
  final Ref _ref;
  Timer? _timer;
  StreamSubscription<UserState>? _subscription;

  MyStopwatchNotifier(this._ref) : super(const AsyncLoading()) {
    _init();
  }

  void _init() {
    final myUserId = _ref.read(myUserIdProvider);
    final repository = _ref.read(userRepositoryProvider);

    // state = const AsyncLoading();

    // final myOwnStateStream = repository.getUserStateStreamFor(myUserId);

    // _subscription = myOwnStateStream.listen((userState) {
    //   state = AsyncData(userState);
    //   repository.updateUserState(userState);
    // });

    // if (state.isLoading) {
    // 초기 상태
    final initialState = UserState(
      userId: myUserId,
      online: true,
      stopwatchRunning: false,
      elapsedTime: 0,
    );

    state = AsyncData(initialState);

    repository.updateUserState(initialState);
    // }

    // 타이머 설정
    _setupTimer();

    // 사용자 상태 스트림 구독 1분에 한번
    Timer.periodic(const Duration(minutes: 1), (_) {
      _ref.listen(allUsersProvider, (previous, next) {
        next.whenData((userMap) {
          if (userMap.containsKey(myUserId)) {
            state = AsyncData(userMap[myUserId]!);
          }
        });
      });
    });
  }

  void _setupTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is AsyncData) {
        final currentState = (state as AsyncData<UserState>).value;
        if (currentState.stopwatchRunning) {
          final updatedState = currentState.copyWith(
            elapsedTime: currentState.elapsedTime + 1,
          );
          state = AsyncData(updatedState);

          // 서버에 상태 업데이트
          _ref.read(userRepositoryProvider).updateUserState(updatedState);
        }
      }
    });
  }

  // 스톱워치 시작
  void startStopwatch() {
    if (state is AsyncData) {
      final currentState = (state as AsyncData<UserState>).value;
      if (!currentState.stopwatchRunning) {
        final updatedState = currentState.copyWith(stopwatchRunning: true);
        state = AsyncData(updatedState);

        // 서버에 상태 업데이트
        _ref.read(userRepositoryProvider).updateUserState(updatedState);
      }
    }
  }

  // 스톱워치 정지
  void stopStopwatch() {
    if (state is AsyncData) {
      final currentState = (state as AsyncData<UserState>).value;
      if (currentState.stopwatchRunning) {
        final updatedState = currentState.copyWith(stopwatchRunning: false);
        state = AsyncData(updatedState);

        // 서버에 상태 업데이트
        _ref.read(userRepositoryProvider).updateUserState(updatedState);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
