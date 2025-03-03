import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/providers.dart';
import '../../domain/models/user_state.dart';
import 'user_list_item.dart';

/// 사용자 리스트 위젯 - 클린 아키텍처 패턴에 맞게 뷰만 담당
class UserList extends ConsumerWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 정렬된 사용자 목록 가져오기
    final usersAsync = ref.watch(allUsersProvider);
    
    return usersAsync.when(
      data: (_) {
        // 프로바이더에서 처리된 데이터 사용
        final participants = ref.watch(sortedUsersProvider);
        final activeReadersCount = ref.watch(activeReadersCountProvider);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 섹션 - 책 이름과 참여자 수
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  // 책 이름
                  const Text(
                    '역사는 어떻게 만들어지는가',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3035),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 구분선
                  Container(
                    width: 32,
                    height: 1,
                    color: const Color(0xFFDFE0E6),
                  ),
                  const SizedBox(width: 8),
                  // 참여자 수
                  Row(
                    children: [
                      Text(
                        '$activeReadersCount',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF804EFF),
                        ),
                      ),
                      const Text(
                        '명',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E3035),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '함께 읽는 중',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E3035),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 하단 섹션 - 참여자 목록
            SizedBox(
              height: 110,
              child: UsersHorizontalList(participants: participants),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
    );
  }
}

/// 수평 스크롤 가능한 사용자 목록
class UsersHorizontalList extends StatelessWidget {
  final List<UserState> participants;

  const UsersHorizontalList({
    super.key, 
    required this.participants
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey<String>('user_horizontal_list'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final user = participants[index];

        // 키를 사용하여 위젯 식별 및 깜빡임 방지
        return KeyedSubtree(
          key: ValueKey('user_item_${user.userId}'),
          child: UserListItem(user: user),
        );
      },
    );
  }
}
