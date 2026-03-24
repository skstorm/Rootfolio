import 'package:flutter/material.dart';

import 'debug_service.dart';

/// 릴리스 모드용 No-op 디버그 서비스 구현체
class ReleaseDebugService implements DebugService {
  @override
  bool get isDebugMode => false;

  @override
  void log(String message) {}

  @override
  Widget buildOverlay({
    required Size parentSize,
    required double totalCoverage,
    required double textCoverage,
    required double totalThreshold,
    required double textThreshold,
    String? targetText,
  }) => const SizedBox.shrink();

  @override
  void drawDebugRect(Canvas canvas, Rect rect, Paint paint) {}

  @override
  bool shouldShowHitGrids() => false;
}
