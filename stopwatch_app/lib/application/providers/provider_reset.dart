import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'usercase/usecase_providers.dart';

// 모든 프로바이더 초기화 - 초기화 순서 개선
void resetAllProviders(WidgetRef ref) {
  try {
    // 첫 번째: 모든 state 관련 provider 초기화
    ref.invalidate(allUsersProvider);
    ref.invalidate(myStopwatchProvider);
    
    // 두 번째: 유즈케이스 프로바이더 초기화
    ref.invalidate(authUseCaseProvider);
    ref.invalidate(manageStopwatchUseCaseProvider);
    ref.invalidate(getAllUsersUseCaseProvider);
    ref.invalidate(manageUserConnectionUseCaseProvider);
    ref.invalidate(appInitializationUseCaseProvider);
    
    // 세 번째: 서비스 프로바이더 초기화
    ref.invalidate(userRepositoryProvider);
    
    // 마지막: 기본 설정 provider 초기화
    // 이 초기화가 마지막에 실행되어 새로운 프로바이더들이 생성될 때
    // 이미 빈 userId를 바라보게 됨
    ref.read(userIdProvider.notifier).state = '';
  } catch (e) {
    print('Provider 초기화 중 오류 발생: $e');
  }
}
