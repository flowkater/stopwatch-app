import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/user_state.dart';
import '../providers.dart';

/// 정렬되고 처리된 사용자 목록을 제공하는 프로바이더
final sortedUsersProvider = Provider<List<UserState>>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  
  return usersAsync.when(
    data: (userMap) {
      final participants = userMap.values.toList();
      
      // 사용자 정렬 로직
      participants.sort((a, b) {
        // 우선순위 점수 계산 (낮을수록 높은 우선순위)
        int getPriorityScore(UserState user) {
          if (user.online && user.stopwatchRunning) {
            return 0; // 1순위: 활성화 O, 스톱워치 O
          }
          if (!user.online && user.stopwatchRunning) {
            return 1; // 2순위: 활성화 X, 스톱워치 O
          }
          if (user.online && !user.stopwatchRunning) {
            return 2; // 3순위: 활성화 O, 스톱워치 X
          }
          return 3; // 4순위: 활성화 X, 스톱워치 X
        }

        // 우선순위 비교
        final aPriority = getPriorityScore(a);
        final bPriority = getPriorityScore(b);

        // 우선순위가 같으면 경과 시간으로 정렬 (내림차순)
        if (aPriority == bPriority) {
          return b.elapsedTime.compareTo(a.elapsedTime);
        }

        return aPriority.compareTo(bPriority);
      });
      
      return participants;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 읽기를 함께하는 활성 사용자 수를 제공하는 프로바이더
final activeReadersCountProvider = Provider<int>((ref) {
  final sortedUsers = ref.watch(sortedUsersProvider);
  return sortedUsers.where((user) => user.stopwatchRunning).length;
});

/// 사용자 ID 기반으로 아바타 이미지 URL을 생성하는 유틸리티 프로바이더
final userAvatarUrlProvider = Provider.family<String, String>((ref, userId) {
  // 샘플 이미지 목록
  const sampleImages = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=6',
    'https://i.pravatar.cc/150?img=7',
  ];
  
  // 사용자 ID 기준으로 이미지 선택 (해시코드 이용)
  final imageIndex = userId.hashCode.abs() % sampleImages.length;
  return sampleImages[imageIndex];
});