// 사용자 상태 모델
class UserState {
  final String userId;
  final bool online;
  final bool stopwatchRunning;
  final double elapsedTime;

  const UserState({
    required this.userId,
    required this.online,
    required this.stopwatchRunning,
    required this.elapsedTime,
  });

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      userId: json['userId'],
      online: json['online'],
      stopwatchRunning: json['stopwatchRunning'],
      elapsedTime: (json['elapsedTime'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "online": online,
    "stopwatchRunning": stopwatchRunning,
    "elapsedTime": elapsedTime,
  };

  UserState copyWith({
    String? userId,
    bool? online,
    bool? stopwatchRunning,
    double? elapsedTime,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      online: online ?? this.online,
      stopwatchRunning: stopwatchRunning ?? this.stopwatchRunning,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }
}
