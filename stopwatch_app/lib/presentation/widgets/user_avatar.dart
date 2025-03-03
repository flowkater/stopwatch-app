import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/state/user_display_provider.dart';
import '../../domain/models/user_state.dart';

/// 사용자 프로필 아바타 위젯
class UserAvatar extends ConsumerWidget {
  final UserState user;
  final double radius;
  final bool useHero;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 24,
    this.useHero = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = user.online;
    final avatarUrl = ref.watch(userAvatarUrlProvider(user.userId));

    final avatar = isActive
        ? CircleAvatar(
            key: Key(user.userId),
            radius: radius,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.grey[300],
          )
        : ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.2),
              BlendMode.srcATop,
            ),
            child: CircleAvatar(
              key: Key(user.userId),
              radius: radius,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.grey[300],
            ),
          );

    // 필요한 경우에만 Hero 위젯 사용
    if (useHero) {
      return Hero(
        tag: 'avatar_${user.userId}',
        child: avatar,
      );
    }

    return avatar;
  }
}

/// 상태 표시 아이콘 위젯
class StatusIndicator extends StatelessWidget {
  final bool isActive;
  final bool isRunning;
  final double size;

  const StatusIndicator({
    super.key,
    required this.isActive,
    required this.isRunning,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? (isRunning ? const Color(0xFF804EFF) : const Color(0xFFDFE0E6))
            : const Color(0xFFDFE0E6),
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

/// 경과 시간 포맷 유틸리티 함수
String formatElapsedTime(double timeInSeconds) {
  int totalSeconds = timeInSeconds.round();
  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;

  // 두 자리 숫자로 포맷팅
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = seconds.toString().padLeft(2, '0');

  return '$formattedMinutes:$formattedSeconds';
}