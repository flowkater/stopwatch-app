import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'usercase/usecase_providers.dart';

// 모든 프로바이더 초기화
void resetAllProviders(WidgetRef ref) {
  // 1. 상태 프로바이더 초기화
  ref.invalidate(allUsersProvider);
  ref.invalidate(myStopwatchProvider);
  print('invalidate 1');

  // 2. 유즈케이스 프로바이더 초기화
  ref.invalidate(authUseCaseProvider);
  ref.invalidate(manageStopwatchUseCaseProvider);
  ref.invalidate(getAllUsersUseCaseProvider);
  ref.invalidate(manageUserConnectionUseCaseProvider);
  ref.invalidate(appInitializationUseCaseProvider);
  print('invalidate 2');
  // 3. 서비스 프로바이더 초기화
  ref.invalidate(userRepositoryProvider);
  print('invalidate 3');
  // 4. 설정 프로바이더 초기화 (마지막에 초기화)
  ref.read(userIdProvider.notifier).update((_) => '');
  ref.invalidate(userIdProvider);
  print('invalidate 4');
}
