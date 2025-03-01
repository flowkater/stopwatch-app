import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/providers.dart';
import '../../domain/models/user_state.dart';

class UserList extends ConsumerWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      data: (userMap) {
        final participants = userMap.values.toList();

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final user = participants[index];
              return _UserAvatar(user: user);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final UserState user;

  const _UserAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // 원형 아바타
          CircleAvatar(
            radius: 25,
            backgroundColor:
                user.online
                    ? (user.stopwatchRunning ? Colors.green : Colors.blue)
                    : Colors.grey,
            child: Text(
              user.userId.substring(user.userId.length - 3),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.stopwatchRunning ? '실행 중' : '정지됨',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
