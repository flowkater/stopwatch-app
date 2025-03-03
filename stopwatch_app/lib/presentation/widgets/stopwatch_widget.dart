import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/providers.dart';

class StopwatchWidget extends ConsumerWidget {
  const StopwatchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myStopwatchAsync = ref.watch(myStopwatchProvider);

    return myStopwatchAsync.when(
      data: (userState) {
        // 시간을 분과 초로 변환
        int totalSeconds = userState.elapsedTime.toInt();
        int minutes = totalSeconds ~/ 60;
        int seconds = totalSeconds % 60;

        // 원형 디자인을 위한 컨테이너
        return Center(
          child: GestureDetector(
            onTap:
                () =>
                    userState.stopwatchRunning
                        ? ref.read(myStopwatchProvider.notifier).stopStopwatch()
                        : ref
                            .read(myStopwatchProvider.notifier)
                            .startStopwatch(),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle, // 원형
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 상단 진행 정보
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "최근 진도: ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E3035),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "00",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E3035),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "/",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E3035),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "374쪽",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E3035),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "(0%)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E3035),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
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
                  ),

                  // 안내 텍스트 및 재생/정지 버튼
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        userState.stopwatchRunning
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 12,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userState.stopwatchRunning ? "독서 중..." : "시작하려면 클릭하세요",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
    );
  }
}
