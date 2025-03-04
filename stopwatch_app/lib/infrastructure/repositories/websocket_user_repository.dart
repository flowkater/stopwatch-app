import 'dart:async';
import 'dart:convert';
import 'dart:math' as Math;
import 'package:http/http.dart' as http;

import 'package:web_socket_channel/io.dart';
import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class WebSocketUserRepository implements UserRepository {
  final String serverUrl;
  final String webSocketServerUrl;
  IOWebSocketChannel? _channel;
  StreamController<UserState> _userStateController =
      StreamController<UserState>.broadcast();
  bool _isConnected = false;
  
  // 마지막으로 연결된 사용자 ID 저장 (재연결에 사용)
  String _lastConnectedUserId = '';
  
  // 연결 시도 정보
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  WebSocketUserRepository({
    required this.serverUrl,
    required this.webSocketServerUrl,
  });
  
  /// 현재 연결 상태 확인
  bool get isConnected => _isConnected && _channel != null;
  
  /// 마지막으로 연결된 사용자 ID 반환
  String get lastConnectedUserId => _lastConnectedUserId;

  @override
  Future<void> connect({String? userId}) async {
    // 연결할 사용자 ID 저장 (재연결에 사용)
    if (userId != null && userId.isNotEmpty) {
      _lastConnectedUserId = userId;
    }
    
    // 이미 연결된 상태인지 확인
    if (_isConnected && _channel != null) {
      print("WebSocket: 이미 연결되어 있습니다.");
      
      // 연결 상태 확인
      try {
        // 간단한 ping 메시지를 보내 연결 상태 확인
        _channel!.sink.add('{"ping": true}');
        return;
      } catch (e) {
        // 오류 발생 시 연결이 끊긴 것으로 간주하고 재연결 시도
        print("WebSocket: 연결 확인 중 오류 발생, 재연결 시도");
        _isConnected = false;
      }
    }

    // 기존 연결 종료
    await closeConnection();

    // 스트림 컨트롤러 초기화
    if (_userStateController.isClosed) {
      _userStateController = StreamController<UserState>.broadcast();
    }

    try {
      print("WebSocket: 연결 시도 중...");
      _channel = IOWebSocketChannel.connect(
        webSocketServerUrl,
        pingInterval: const Duration(seconds: 30), // 연결 유지를 위한 ping 설정
      );

      // 스트림 리스너 설정
      _channel!.stream.listen(
        (data) {
          // 연결 성공으로 간주, 재연결 카운터 초기화
          _reconnectAttempts = 0;
          
          try {
            // ping 응답인 경우 처리하지 않음
            if (data.toString().contains('"ping"')) {
              return;
            }
            
            final decoded = jsonDecode(data);
            final userState = UserState.fromJson(decoded);
            if (!_userStateController.isClosed) {
              _userStateController.add(userState);
            }
          } catch (e) {
            print("WebSocket: 데이터 파싱 오류: $e");
          }
        },
        onError: (err) {
          print("WebSocket 오류: $err");
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          print("WebSocket 연결 종료됨");
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      _isConnected = true;
      print("WebSocket 연결 성공");
    } catch (e) {
      print("WebSocket 연결 실패: $e");
      _isConnected = false;
      _scheduleReconnect();
    }
  }
  
  /// 재연결 스케줄링
  void _scheduleReconnect() {
    // 이미 재연결 타이머가 실행 중이면 중단
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return;
    }
    
    // 최대 재시도 횟수 체크
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print("WebSocket: 최대 재연결 시도 횟수 초과, 재연결 중단");
      return;
    }
    
    // 사용자 ID가 없으면 재연결하지 않음
    if (_lastConnectedUserId.isEmpty) {
      print("WebSocket: 연결된 사용자 ID가 없어 재연결하지 않음");
      return;
    }
    
    _reconnectAttempts++;
    
    // 지수 백오프 방식으로 재연결 시간 계산 (1초, 2초, 4초, 8초, 16초)
    final backoffDelay = Duration(
      milliseconds: (1000 * Math.pow(2, _reconnectAttempts - 1)).toInt()
    );
    
    print("WebSocket: ${backoffDelay.inSeconds}초 후 재연결 시도 (${_reconnectAttempts}/${maxReconnectAttempts})");
    
    _reconnectTimer = Timer(backoffDelay, () {
      print("WebSocket: 재연결 시도 중...");
      connect(userId: _lastConnectedUserId);
    });
  }
  
  /// 연결 상태 체크 및 복구
  Future<bool> checkConnection() async {
    if (_isConnected && _channel != null) {
      return true;
    }
    
    // 마지막 연결된 사용자 ID가 있으면 재연결 시도
    if (_lastConnectedUserId.isNotEmpty) {
      print("WebSocket: 연결이 끊어진 상태, 재연결 시도");
      await connect(userId: _lastConnectedUserId);
      return _isConnected;
    }
    
    return false;
  }

  @override
  Future<void> closeConnection() async {
    try {
      if (!_userStateController.isClosed) {
        await _userStateController.close();
      }

      if (_channel != null) {
        await _channel!.sink.close();
        _channel = null;
      }

      _isConnected = false;
      print("WebSocket 연결 종료");
    } catch (e) {
      print('연결 종료 중 오류: $e');
    }
  }

  @override
  Future<void> updateUserState(UserState userState) async {
    try {
      if (!_isConnected || _channel == null) {
        return;
      }
      _channel!.sink.add(jsonEncode(userState.toJson()));
    } catch (e) {
      print('상태 업데이트 중 오류: $e');
    }
  }

  @override
  Stream<UserState> getUserStateStream() {
    return _userStateController.stream;
  }

  @override
  Stream<UserState> getUserStateStreamFor(String userId) {
    return _userStateController.stream.where((event) => event.userId == userId);
  }

  @override
  Future<UserState> getUserState(String userId) async {
    final response = await http.get(
      Uri.parse('$serverUrl/api/user-states/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=utf-8', // UTF-8 명시
        'Accept-Charset': 'utf-8',
      },
    );

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);
      print('getUserState: $data');
      return UserState.fromJson(data);
    } else {
      throw Exception('Failed to load user state: ${response.statusCode}');
    }
  }

  @override
  Future<List<UserState>> getAllUserStates() async {
    try {
      final response = await http
          .get(
            Uri.parse('$serverUrl/api/user-states'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('모든 사용자 상태 요청 시간 초과'),
          );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        print('decodedBody: $decodedBody');
        final List<dynamic> data = json.decode(decodedBody);
        print('getAllUserStates: $data');
        return data.map((item) => UserState.fromJson(item)).toList();
      } else {
        throw Exception('모든 사용자 상태 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('모든 사용자 상태 가져오기 오류: $e');
      // 빈 리스트 반환 또는 예외 던지기
      return [];
    }
  }
}
