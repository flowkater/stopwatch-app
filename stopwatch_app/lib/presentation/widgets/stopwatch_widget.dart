import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/providers.dart';
import '../../domain/models/user_state.dart';

/// 스톱워치 UI 위젯
/// 현재 사용자의 스톱워치 상태를 표시하고 시작/정지 기능 및 애니메이션 제공
class StopwatchWidget extends ConsumerStatefulWidget {
  const StopwatchWidget({super.key});

  @override
  ConsumerState<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends ConsumerState<StopwatchWidget> 
    with SingleTickerProviderStateMixin {
  
  // 펄스 애니메이션을 위한 컨트롤러
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // 이전 실행 상태
  bool _wasRunning = false;
  
  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // 1.5초 주기
    );
    
    // 크기가 작아졌다 커지는 애니메이션 (1.0 ~ 1.05)
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.04)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_pulseController);
    
    // 무한 반복
    _pulseController.repeat();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 내 스톱워치 상태 구독
    final myStopwatchAsync = ref.watch(myStopwatchProvider);

    // 비동기 상태에 따른 UI 렌더링
    return myStopwatchAsync.when(
      // 데이터 로드 완료
      data: (userState) {
        // 스톱워치 상태가 변경되었는지 확인
        _checkAndUpdateAnimationState(userState.stopwatchRunning);
        
        return _buildStopwatchContent(context, userState);
      },
      
      // 로딩 중
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      
      // 오류 발생
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              '스톱워치 로드 오류: $error',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 애니메이션 상태 업데이트 확인
  void _checkAndUpdateAnimationState(bool isRunning) {
    // 상태가 변경되었을 때만 애니메이션 변경
    if (isRunning != _wasRunning) {
      _wasRunning = isRunning;
      
      if (isRunning) {
        // 스톱워치 시작 시 애니메이션 시작
        _pulseController.repeat();
      } else {
        // 스톱워치 정지 시 애니메이션 정지 및 초기 상태로
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }
  
  /// 스톱워치 콘텐츠 UI 구성
  Widget _buildStopwatchContent(
    BuildContext context, 
    UserState userState
  ) {
    // 시간을 분과 초로 변환
    int totalSeconds = userState.elapsedTime.toInt();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    
    // 애니메이션 적용된 원형 디자인 (텍스트는 고정)
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 애니메이션이 적용된 배경 원
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: userState.stopwatchRunning ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // 2. 고정된 내용 (이 부분은 애니메이션의 영향을 받지 않음)
          GestureDetector(
            onTap: () => _toggleStopwatch(userState),
            child: SizedBox(
              width: 280,
              height: 280,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 상단 진행 정보
                  _buildBookProgressInfo(),
                  
                  // 타이머 표시
                  _buildTimerDisplay(minutes, seconds),

                  // 안내 텍스트 및 재생/정지 아이콘
                  const SizedBox(height: 8.0),
                  _buildStatusIndicator(userState.stopwatchRunning),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 책 진행 정보 표시 위젯
  Widget _buildBookProgressInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "최근 진도: ",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2E3035),
            ),
          ),
          SizedBox(width: 4),
          Text(
            "00",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2E3035),
            ),
          ),
          SizedBox(width: 4),
          Text(
            "/",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2E3035),
            ),
          ),
          SizedBox(width: 4),
          Text(
            "374쪽",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2E3035),
            ),
          ),
          SizedBox(width: 2),
          Text(
            "(0%)",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2E3035),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 타이머 시간 표시 위젯
  Widget _buildTimerDisplay(int minutes, int seconds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          minutes.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w100,
            color: Color(0xFF2E3035),
          ),
        ),
        const Text(
          ":",
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w100,
            color: Color(0xFF2E3035),
          ),
        ),
        Text(
          seconds.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w100,
            color: Color(0xFF2E3035),
          ),
        ),
      ],
    );
  }
  
  /// 상태 표시 위젯 (재생/정지 아이콘과 텍스트)
  Widget _buildStatusIndicator(bool isRunning) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isRunning ? Icons.pause : Icons.play_arrow,
          size: 12,
          color: isRunning ? Colors.red : Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          isRunning ? "독서 중..." : "시작하려면 클릭하세요",
          style: TextStyle(
            fontSize: 12,
            color: isRunning ? Colors.red : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  /// 스톱워치 시작/정지 토글 메서드
  void _toggleStopwatch(UserState userState) {
    if (userState.stopwatchRunning) {
      ref.read(myStopwatchProvider.notifier).stopStopwatch();
    } else {
      ref.read(myStopwatchProvider.notifier).startStopwatch();
    }
  }
}
