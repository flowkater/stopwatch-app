import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import '../../domain/models/user_state.dart';
import '../../domain/repositories/user_repository.dart';

class WebSocketUserRepository implements UserRepository {
  final String serverUrl;
  late IOWebSocketChannel _channel;
  final _userStateController = StreamController<UserState>.broadcast();

  WebSocketUserRepository({required this.serverUrl});

  @override
  Future<void> connect() async {
    _channel = IOWebSocketChannel.connect(serverUrl);

    _channel.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        final userState = UserState.fromJson(decoded);
        _userStateController.add(userState);
      },
      onError: (err) {
        print("WebSocket error: $err");
        // 에러 처리 로직 추가 가능
      },
      onDone: () {
        print("WebSocket closed");
        // 재연결 로직 추가 가능
      },
    );
  }

  @override
  Future<void> updateUserState(UserState userState) async {
    _channel.sink.add(jsonEncode(userState.toJson()));
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
  Future<void> closeConnection() async {
    await _channel.sink.close();
    await _userStateController.close();
  }
}
