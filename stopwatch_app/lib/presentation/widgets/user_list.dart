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
/// AnimatedSwitcher와 AnimatedPositioned를 사용하여 부드러운 위치 전환 제공
class UsersHorizontalList extends StatefulWidget {
  final List<UserState> participants;

  const UsersHorizontalList({super.key, required this.participants});

  @override
  State<UsersHorizontalList> createState() => _UsersHorizontalListState();
}

class _UsersHorizontalListState extends State<UsersHorizontalList> {
  // 사용자 ID를 key로 사용하여 이전 포지션 캐시
  final Map<String, int> _previousPositions = {};

  @override
  Widget build(BuildContext context) {
    // 현재 사용자 위치 매핑 업데이트
    final Map<String, int> currentPositions = {};
    for (int i = 0; i < widget.participants.length; i++) {
      currentPositions[widget.participants[i].userId] = i;
    }

    return SizedBox(
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          // 스크롤 컨테이너 (스크롤 기능 제공)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: List.generate(
                widget.participants.length,
                (index) => const SizedBox(width: 64), // 빈 공간 예약 (아이템 너비 + 마진)
              ),
            ),
          ),

          // 애니메이션 사용자 아이템들
          ...widget.participants.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final userId = user.userId;

            // 이전 위치와 현재 위치
            final previousPosition = _previousPositions[userId] ?? index;
            final currentPosition = index;

            // 위치 변경 여부 감지 (주석 처리된 코드는 디버깅 목적)
            final bool hasPositionChanged = previousPosition != currentPosition;
            // if (hasPositionChanged) {
            //   print('사용자 $userId: $previousPosition -> $currentPosition 위치로 이동');
            // }

            // 위치 업데이트
            _previousPositions[userId] = currentPosition;

            return AnimatedPositioned(
              key: ValueKey('user_position_$userId'),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: 10.0 + (index * 64.0), // 64 = 아이템 너비 (56) + 좌우 마진 (8)
              top: 0,
              height: 110,
              width: 56,
              child: TweenAnimationBuilder<double>(
                key: ValueKey('user_item_$userId'),
                tween: Tween<double>(
                  begin: hasPositionChanged ? 0.8 : 1.0,
                  end: 1.0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: UserListItem(user: user),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(UsersHorizontalList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 사용자 목록이 변경되면 새 사용자의 위치 추가
    for (int i = 0; i < widget.participants.length; i++) {
      final userId = widget.participants[i].userId;
      if (!_previousPositions.containsKey(userId)) {
        _previousPositions[userId] = i;
      }
    }

    // 더 이상 존재하지 않는 사용자 제거
    _previousPositions.removeWhere(
      (userId, _) => !widget.participants.any((user) => user.userId == userId),
    );
  }
}
