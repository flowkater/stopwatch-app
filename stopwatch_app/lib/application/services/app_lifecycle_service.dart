import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/config/user_id_provider.dart';
import '../providers/service/user_repository_provider.dart';

/// 앱 생명주기 관리 서비스
/// 
/// 앱이 포그라운드/백그라운드로 전환될 때 필요한 작업을 수행
class AppLifecycleService with WidgetsBindingObserver {
  final Ref _ref;
  
  // 마지막으로 알려진 앱 상태
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;
  
  // 재연결 타이머
  Timer? _reconnectTimer;
  
  AppLifecycleService(this._ref) {
    // 생명주기 옵저버 등록
    WidgetsBinding.instance.addObserver(this);
  }
  
  /// 생명주기 변경 이벤트 처리
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('앱 생명주기 변경: $_lastLifecycleState -> $state');
    _lastLifecycleState = state;
    
    _handleLifecycleChange(state);
  }
  
  /// 생명주기 변경에 따른 처리
  void _handleLifecycleChange(AppLifecycleState state) async {
    final userId = _ref.read(userIdProvider);
    
    // 로그인 상태가 아니면 아무 작업도 하지 않음
    if (userId.isEmpty) {
      return;
    }
    
    switch (state) {
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아오면 연결 확인 및 복구
        await _checkAndRestoreConnection(userId);
        break;
        
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 가면 타이머 예약 (5분 후 연결 확인)
        _scheduleConnectionCheck();
        break;
        
      case AppLifecycleState.detached:
        // 앱이 종료 중이면 타이머 취소
        _cancelReconnectTimer();
        break;
        
      default:
        // 다른 상태 (inactive, hidden 등)는 무시
        break;
    }
  }
  
  /// 연결 확인 및 필요시 복구
  Future<void> _checkAndRestoreConnection(String userId) async {
    print('웹소켓 연결 상태 확인 중...');
    
    // 타이머 취소
    _cancelReconnectTimer();
    
    try {
      final repository = _ref.read(userRepositoryProvider);
      
      // 연결 체크 및 복구 시도
      final isConnected = await repository.checkConnection();
      
      if (isConnected) {
        print('웹소켓 연결 유지 중');
      } else {
        print('웹소켓 연결 복구 필요, userId=$userId로 연결 시도');
        await repository.connect(userId: userId);
      }
    } catch (e) {
      print('연결 확인 중 오류: $e');
    }
  }
  
  /// 재연결 체크 타이머 설정 (앱이 백그라운드에 있을 때)
  void _scheduleConnectionCheck() {
    // 기존 타이머 취소
    _cancelReconnectTimer();
    
    // 5분 후 연결 확인 예약
    _reconnectTimer = Timer(const Duration(minutes: 5), () async {
      final userId = _ref.read(userIdProvider);
      if (userId.isNotEmpty) {
        await _checkAndRestoreConnection(userId);
      }
    });
  }
  
  /// 타이머 취소
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// 서비스 정리
  void dispose() {
    _cancelReconnectTimer();
    WidgetsBinding.instance.removeObserver(this);
  }
}