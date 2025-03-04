/// 사용자 및 스톱워치 상태를 나타내는 도메인 모델
/// 
/// 이 모델은 사용자 식별, 온라인 상태, 스톱워치 실행 상태, 
/// 경과 시간에 관한 데이터를 포함합니다.
class UserState {
  /// 사용자 고유 식별자
  final String userId;
  
  /// 온라인 상태 (접속 중인지 여부)
  final bool online;
  
  /// 스톱워치 실행 여부
  final bool stopwatchRunning;
  
  /// 경과 시간 (초 단위)
  final double elapsedTime;

  /// 사용자 상태 생성자
  const UserState({
    required this.userId,
    required this.online,
    required this.stopwatchRunning,
    required this.elapsedTime,
  });

  /// JSON 데이터에서 UserState 객체 생성
  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      userId: json['userId'] as String,
      online: json['online'] as bool,
      stopwatchRunning: json['stopwatchRunning'] as bool,
      elapsedTime: (json['elapsedTime'] as num).toDouble(),
    );
  }

  /// UserState 객체를 JSON 맵으로 변환
  Map<String, dynamic> toJson() => {
    "userId": userId,
    "online": online,
    "stopwatchRunning": stopwatchRunning,
    "elapsedTime": elapsedTime,
  };

  /// 불변 객체 패턴을 위한 복사 메서드
  /// 일부 속성만 변경한 새 인스턴스 생성
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
  
  /// 디버깅 및 로깅을 위한 문자열 표현
  @override
  String toString() {
    return 'UserState{userId: $userId, online: $online, '
           'stopwatchRunning: $stopwatchRunning, '
           'elapsedTime: $elapsedTime}';
  }
  
  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserState &&
           other.userId == userId &&
           other.online == online &&
           other.stopwatchRunning == stopwatchRunning &&
           other.elapsedTime == elapsedTime;
  }
  
  /// 해시코드 생성
  @override
  int get hashCode => 
      userId.hashCode ^ 
      online.hashCode ^ 
      stopwatchRunning.hashCode ^ 
      elapsedTime.hashCode;
}
