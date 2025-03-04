import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/user_state.dart';
import '../config/user_id_provider.dart';
import '../usercase/usecase_providers.dart';

/// 모든 사용자의 상태를 관리하는 프로바이더
/// 인증 상태(userIdProvider)에 따라 자동으로 초기화 및 정리됨
final allUsersProvider =
    StateNotifierProvider<AllUsersNotifier, AsyncValue<Map<String, UserState>>>(
      (ref) {
        // userId를 의존성으로 추가하여 로그아웃 시 자동으로 초기화되도록 함
        final userId = ref.watch(userIdProvider);
        final isAuthenticated = userId.isNotEmpty;
        
        return AllUsersNotifier(ref, isAuthenticated: isAuthenticated);
      },
    );

/// 모든 사용자의 상태를 관리하는 StateNotifier
/// - 웹소켓 스트림을 구독하여 실시간 업데이트 처리
/// - 인증 상태에 따라 초기화 및 정리
class AllUsersNotifier
    extends StateNotifier<AsyncValue<Map<String, UserState>>> {
  final Ref _ref;
  final bool _isAuthenticated;
  final Map<String, UserState> _userMap = {};
  StreamSubscription<UserState>? _subscription;

  AllUsersNotifier(this._ref, {required bool isAuthenticated}) 
      : _isAuthenticated = isAuthenticated,
        super(const AsyncLoading()) {
    if (_isAuthenticated) {
      _initializeUserStates();
    } else {
      // 인증되지 않은 경우 빈 데이터 반환
      state = const AsyncData({});
    }
  }

  /// 사용자 상태 초기화 및 스트림 구독
  Future<void> _initializeUserStates() async {
    if (!_isAuthenticated) {
      return;
    }
    
    final useCase = _ref.read(getAllUsersUseCaseProvider);

    try {
      // 로딩 상태로 설정
      state = const AsyncLoading();

      // 초기 사용자 상태 가져오기
      final initialUsers = await useCase.getAllInitialUserStates();
      
      // 초기 상태를 맵에 설정
      _userMap.clear();
      for (var user in initialUsers) {
        _userMap[user.userId] = user;
      }

      // 이미 로그아웃된 경우 빈 데이터 반환
      if (!_isAuthenticated) {
        state = const AsyncData({});
        return;
      }

      // 데이터 업데이트
      state = AsyncData(Map.unmodifiable(_userMap));
      
      // 사용자 상태 스트림 구독
      _subscribeToUserStateStream(useCase);
    } catch (e) {
      // 인증 상태 확인
      if (!_isAuthenticated) {
        state = const AsyncData({});
        return;
      }
      
      // 오류 상태로 설정
      state = AsyncError(e, StackTrace.current);
    }
  }
  
  /// 사용자 상태 스트림 구독 설정
  void _subscribeToUserStateStream(useCase) {
    _subscription = useCase.getAllUserStates().listen(
      (userState) {
        // 새 사용자 상태 업데이트
        _userMap[userState.userId] = userState;
        state = AsyncData(Map.unmodifiable(_userMap));
      }, 
      onError: (error) {
        if (_isAuthenticated) {
          state = AsyncError(error, StackTrace.current);
        }
      }
    );
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// 자원 정리 (스트림 구독 취소 및 데이터 초기화)
  void _cleanupResources() {
    try {
      _subscription?.cancel();
      _subscription = null;
      _userMap.clear();
    } catch (e) {
      // 리소스 정리 중 오류 무시
    }
  }
}
