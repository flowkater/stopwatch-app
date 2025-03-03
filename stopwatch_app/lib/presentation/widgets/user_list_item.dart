import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/user_state.dart';
import 'user_avatar.dart';

/// 사용자 리스트 아이템 (애니메이션 처리 포함)
class UserListItem extends StatefulWidget {
  final UserState user;

  const UserListItem({super.key, required this.user});

  @override
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  Timer? _timer;
  late double _currentElapsedTime;

  @override
  void initState() {
    super.initState();
    _currentElapsedTime = widget.user.elapsedTime;

    // 애니메이션 컨트롤러 초기화
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );

    // 애니메이션 시작
    _opacityController.forward();

    // 스톱워치가 실행 중인 경우 타이머 시작
    if (widget.user.stopwatchRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(UserListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 사용자 상태가 변경된 경우 타이머 업데이트
    if (oldWidget.user.stopwatchRunning != widget.user.stopwatchRunning ||
        oldWidget.user.elapsedTime != widget.user.elapsedTime) {
      _currentElapsedTime = widget.user.elapsedTime;

      // 타이머 정리
      _disposeTimer();

      // 스톱워치가 실행 중인 경우 새 타이머 시작
      if (widget.user.stopwatchRunning) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentElapsedTime += 1.0;
        });
      }
    });
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _disposeTimer();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                // 사용자 상태 (아바타 + 상태 표시)
                Stack(
                  children: [
                    // 프로필 아바타
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: UserAvatar(user: user),
                    ),

                    // 상태 표시 점
                    Positioned(
                      left: 4,
                      top: 10,
                      child: StatusIndicator(
                        isActive: user.online,
                        isRunning: user.stopwatchRunning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 타이머 표시 - 실시간 업데이트된 시간 표시
                Text(
                  formatElapsedTime(_currentElapsedTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E3035),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
