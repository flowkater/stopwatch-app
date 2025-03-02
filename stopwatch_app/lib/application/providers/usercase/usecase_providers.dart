import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../usecases/app_initialization_usecase.dart';
import '../../usecases/manage_user_connection_usecase.dart';
import '../../usecases/get_all_users_usecase.dart';
import '../../usecases/manage_stopwatch_usecase.dart';
import '../../usecases/auth_usecase.dart';
import '../service/user_repository_provider.dart';

// 앱 초기화 유즈케이스 프로바이더
final appInitializationUseCaseProvider = Provider<AppInitializationUseCase>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return AppInitializationUseCase(repository);
});

// 유즈케이스 프로바이더들
final manageUserConnectionUseCaseProvider =
    Provider<ManageUserConnectionUseCase>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return ManageUserConnectionUseCase(repository);
    });

final getAllUsersUseCaseProvider = Provider<GetAllUsersUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetAllUsersUseCase(repository);
});

final manageStopwatchUseCaseProvider = Provider<ManageStopwatchUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return ManageStopwatchUseCase(repository);
});

final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  final initUseCase = ref.watch(appInitializationUseCaseProvider);

  return AuthUseCase(repository, initUseCase, ref);
});
