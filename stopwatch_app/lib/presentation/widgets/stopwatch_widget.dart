import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/user_provider.dart';

class StopwatchWidget extends ConsumerWidget {
  const StopwatchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myStopwatchAsync = ref.watch(myStopwatchProvider);

    return myStopwatchAsync.when(
      data: (userState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "내 스톱워치: ${userState.elapsedTime.toStringAsFixed(0)}초",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              userState.stopwatchRunning
                  ? ElevatedButton(
                    onPressed:
                        () =>
                            ref
                                .read(myStopwatchProvider.notifier)
                                .stopStopwatch(),
                    child: const Text('정지'),
                  )
                  : ElevatedButton(
                    onPressed:
                        () =>
                            ref
                                .read(myStopwatchProvider.notifier)
                                .startStopwatch(),
                    child: const Text('시작'),
                  ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
    );
  }
}
