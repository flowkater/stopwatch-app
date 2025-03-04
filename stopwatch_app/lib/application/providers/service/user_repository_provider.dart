import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/repositories/user_repository.dart';
import '../../../infrastructure/repositories/websocket_user_repository.dart';
import '../config/constants.dart';
import '../config/user_id_provider.dart';

/// 웹소켓 레포지토리 프로바이더 - 인증 상태에 따라 연결 관리
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // 사용자 ID 의존성 추가
  final userId = ref.watch(userIdProvider);
  final isAuthenticated = userId.isNotEmpty;
  
  // 웹소켓 레포지토리 인스턴스 생성
  final repository = WebSocketUserRepository(
    serverUrl: serverUrl,
    webSocketServerUrl: webSocketServerUrl,
  );

  // 인증된 경우에만 연결
  if (isAuthenticated) {
    print('Repository: 인증된 상태, 연결 시도');
    // 연결은 별도로 하지 않고, AppInitializationUseCase에서 관리하도록 변경
    // repository.connect();
  } else {
    print('Repository: 인증되지 않은 상태, 연결 하지 않음');
    // 인증되지 않은 경우 연결 종료
    repository.closeConnection();
  }

  // 프로바이더가 dispose될 때 연결 종료
  ref.onDispose(() {
    print('Repository: dispose - 연결 종료');
    repository.closeConnection();
  });

  return repository;
});
