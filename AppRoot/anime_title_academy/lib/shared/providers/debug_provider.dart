import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/injection_container.dart';
import '../debug/debug_service.dart';
import '../debug/dev_debug_service.dart';
import '../debug/release_debug_service.dart';
import '../logging/app_logger.dart';

/// 디버그 활성화 상태를 관리하는 노티파이어
class DebugEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => kDebugMode;

  void toggle() => state = !state;
}

/// 디버그 활성화 상태 프로바이더 (기본값: kDebugMode)
final debugEnabledProvider = NotifierProvider<DebugEnabledNotifier, bool>(() {
  return DebugEnabledNotifier();
});

/// 디버그 서비스 프로바이더
final debugServiceProvider = Provider<DebugService>((ref) {
  final isEnabled = ref.watch(debugEnabledProvider);
  final logger = getIt<AppLogger>();
  
  if (kDebugMode) {
    return DevelopmentDebugService(logger: logger, isEnabled: isEnabled);
  } else {
    // 릴리스 모드에서는 항상 No-op 서비스 제공
    return ReleaseDebugService();
  }
});
