// import 'package:flutter/foundation.dart';

// 개발 환경 설정 (true: 개발 환경, false: 프로덕션 환경)
const bool isDev = false;
// const bool isDev = kDebugMode;

// 서버 URL 설정
const serverUrl =
    isDev
        ? 'http://localhost:3000'
        : 'https://stopwatch-server-quiet-cherry-718.fly.dev';

// 웹소켓 서버 URL 설정
const webSocketServerUrl =
    isDev
        ? 'ws://localhost:3000/ws'
        : 'wss://stopwatch-server-quiet-cherry-718.fly.dev/ws';
