import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_app/application/providers/provider_reset.dart';
import '../../application/providers/providers.dart';
import '../../application/providers/usercase/usecase_providers.dart';
import '../widgets/user_list.dart';
import '../widgets/stopwatch_widget.dart';
import 'login_page.dart';

class StopwatchPage extends ConsumerWidget {
  const StopwatchPage({super.key});

  // 로그아웃 처리
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // 확인 다이얼로그 표시
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );

    if (shouldLogout != true) {
      return;
    }

    // 로그아웃 유즈케이스 실행
    final userId = ref.read(userIdProvider);
    final authUseCase = ref.read(authUseCaseProvider);

    try {
      await authUseCase.logout(userId);
      // 사용자 ID 프로바이더 초기화
      resetAllProviders(ref);
      // 로그인 페이지로 이동
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false, // 모든 이전 경로 제거
        );
      }
    } catch (e) {
      // 에러 처리
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 사용자 ID 가져오기
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 스톱워치'),
        actions: [
          // 사용자 ID 표시
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                userId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const UserList(),
          const Divider(),
          const Expanded(child: StopwatchWidget()),
        ],
      ),
    );
  }
}
