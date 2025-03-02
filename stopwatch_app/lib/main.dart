import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch_app/application/providers/usercase/usecase_providers.dart';

import 'application/providers/providers.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/stopwatch_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences에서 사용자 ID 가져오기
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId') ?? '';

  final container = ProviderContainer(
    overrides: [userIdProvider.overrideWith((ref) => userId)],
  );

  // 사용자 ID가 있으면 앱 초기화 수행
  if (userId.isNotEmpty) {
    try {
      final initUseCase = container.read(appInitializationUseCaseProvider);
      await initUseCase.initializeApp(userId);
    } catch (e) {
      print('앱 초기화 오류: $e');
      // 오류 처리 (예: 사용자 ID 삭제)
      await prefs.remove('userId');
    }
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자 ID 가져오기
    final userId = ref.watch(userIdProvider);

    return MaterialApp(
      title: '실시간 스톱워치',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // 사용자 ID가 있으면 스톱워치 페이지로, 없으면 로그인 페이지로 이동
      home: userId.isNotEmpty ? const StopwatchPage() : const LoginPage(),
    );
  }
}
