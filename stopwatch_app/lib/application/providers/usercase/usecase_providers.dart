import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../usecases/manage_user_connection_usecase.dart';
import '../../usecases/get_all_users_usecase.dart';
import '../../usecases/manage_stopwatch_usecase.dart';
import '../service/user_repository_provider.dart';

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
