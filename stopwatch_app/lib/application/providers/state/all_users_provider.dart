import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/user_state.dart';
import '../usercase/usecase_providers.dart';

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
    final useCase = _ref.read(getAllUsersUseCaseProvider);
    final connectionUseCase = _ref.read(manageUserConnectionUseCaseProvider);

    // 연결 시작
    connectionUseCase.connect();

    // 스트림 구독
    _subscription = useCase.getAllUserStates().listen((userState) {
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
