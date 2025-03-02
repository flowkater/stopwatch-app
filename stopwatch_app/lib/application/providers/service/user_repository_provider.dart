import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/repositories/user_repository.dart';
import '../../../infrastructure/repositories/websocket_user_repository.dart';
import '../config/constants.dart';

// 웹소켓 레포지토리 프로바이더
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final repository = WebSocketUserRepository(
    serverUrl: serverUrl,
    webSocketServerUrl: webSocketServerUrl,
  );

  // 연결 시작
  repository.connect();

  // 프로바이더가 dispose될 때 연결 종료
  ref.onDispose(() {
    repository.closeConnection();
  });

  return repository;
});
