import 'package:flutter_riverpod/flutter_riverpod.dart';

// 사용자 ID 프로바이더 (StateProvider로 변경 가능하도록)
final userIdProvider = StateProvider<String>((ref) => '');

// 내 사용자 ID 프로바이더 (기존 myUserIdProvider 대체)
final myUserIdProvider = Provider<String>((ref) {
  return ref.watch(userIdProvider);
});
