import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/app_lifecycle_service.dart';

/// 앱 생명주기 서비스 프로바이더
/// 
/// 앱의 라이프사이클을 관리하고 백그라운드/포그라운드 전환 시 필요한 작업 수행
final appLifecycleProvider = Provider<AppLifecycleService>((ref) {
  final service = AppLifecycleService(ref);
  
  // 프로바이더가 폐기될 때 서비스도 정리
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});