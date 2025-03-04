import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_state.dart';
import 'user_avatar.dart';

/// 사용자 리스트 아이템 위젯
/// 
/// 각 사용자의 아바타, 상태 표시, 경과 시간을 표시하며
/// 스톱워치 실행 중일 때 실시간으로 시간을 업데이트합니다.
class UserListItem extends StatefulWidget {
  final UserState user;

  const UserListItem({super.key, required this.user});

  @override
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  Timer? _timer;
  late double _currentElapsedTime;
  
  @override
  void initState() {
    super.initState();
    _currentElapsedTime = widget.user.elapsedTime;
    
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

  /// 1초마다 경과 시간을 업데이트하는 타이머 시작
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentElapsedTime += 1.0;
        });
      }
    });
  }

  /// 타이머 정리
  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    
    // 위젯 효율성을 위해 AnimatedContainer 사용
    return Container(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                child: AnimatedStatusIndicator(
                  isActive: user.online,
                  isRunning: user.stopwatchRunning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 타이머 표시 - 실시간 업데이트된 시간 표시
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              formatElapsedTime(_currentElapsedTime),
              key: ValueKey('time_${_currentElapsedTime.toInt()}'),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2E3035),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상태 표시기 위젯 - 애니메이션 효과가 추가된 버전
class AnimatedStatusIndicator extends StatelessWidget {
  final bool isActive;
  final bool isRunning;
  final double size;

  const AnimatedStatusIndicator({
    Key? key,
    required this.isActive,
    required this.isRunning,
    this.size = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 상태에 따른 색상 결정
    final color = isActive
        ? (isRunning ? const Color(0xFF804EFF) : const Color(0xFFDFE0E6))
        : const Color(0xFFDFE0E6);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
