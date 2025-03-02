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

  void _init() async {
    final useCase = _ref.read(getAllUsersUseCaseProvider);

    try {
      state = const AsyncLoading();

      // 모든 사용자 상태를 가져오는 메서드 추가 필요
      final initialUsers = await useCase.getAllInitialUserStates();

      // 초기 상태 설정
      for (var user in initialUsers) {
        _userMap[user.userId] = user;
      }

      state = AsyncData(_userMap);
    } catch (e) {
      print('초기 사용자 상태 로딩 실패: $e');
      // 오류가 있어도 스트림 구독은 계속 진행
    }

    // 스트림 구독
    _subscription = useCase.getAllUserStates().listen((userState) {
      _userMap[userState.userId] = userState;
      state = AsyncData(_userMap);
    });
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _userMap.clear();
  }
}
