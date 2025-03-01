import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/providers/providers.dart';
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

    // SharedPreferences에서 사용자 ID 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    // 사용자 ID 프로바이더 초기화
    ref.read(userIdProvider.notifier).update((_) => '');

    // 로그인 페이지로 이동
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
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
          // (1) 상단: 원형 프로필 목록 (인스타 스토리 UI 유사)
          const UserList(),

          const Divider(),

          // (2) 내 스톱워치 UI
          const Expanded(child: StopwatchWidget()),
        ],
      ),
    );
  }
}
