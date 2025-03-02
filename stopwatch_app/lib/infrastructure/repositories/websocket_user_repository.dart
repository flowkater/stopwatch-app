import 'dart:async';
import 'dart:convert';
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

  WebSocketUserRepository({
    required this.serverUrl,
    required this.webSocketServerUrl,
  });

  @override
  Future<void> connect() async {
    if (_isConnected && _channel != null) {
      print("이미 연결되어 있습니다.");
      return;
    }

    await closeConnection();

    if (_userStateController.isClosed) {
      _userStateController = StreamController<UserState>.broadcast();
    }

    _channel = IOWebSocketChannel.connect(webSocketServerUrl);

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        final userState = UserState.fromJson(decoded);
        if (!_userStateController.isClosed) {
          print('userState: ${userState.toJson()}');
          _userStateController.add(userState);
        }
      },
      onError: (err) {
        print("WebSocket error: $err");
        _isConnected = false;
      },
      onDone: () {
        print("WebSocket closed");
        _isConnected = false;
      },
    );

    _isConnected = true;
    print("WebSocket 연결 성공");
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
