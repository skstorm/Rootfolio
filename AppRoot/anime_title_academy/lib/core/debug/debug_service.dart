import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 디버그 서비스 인터페이스
abstract class DebugService {
  bool get isDebugMode;

  static void debugLog(String message, {String scope = 'DebugService'}) {
    if (!kDebugMode) return;
    print('[$scope] $message');
    developer.log(message, name: scope, level: 500);
  }

  static Stopwatch startTimer(String label, {String scope = 'DebugService'}) {
    final stopwatch = Stopwatch()..start();
    debugLog('$label started', scope: scope);
    return stopwatch;
  }

  static void endTimer(
    String label,
    Stopwatch stopwatch, {
    String scope = 'DebugService',
    String? details,
  }) {
    if (!kDebugMode) return;
    if (stopwatch.isRunning) {
      stopwatch.stop();
    }

    final suffix = details == null || details.isEmpty ? '' : ' | $details';
    debugLog(
      '$label completed in ${stopwatch.elapsedMilliseconds}ms$suffix',
      scope: scope,
    );
  }

  static void cacheHit(String label, {String scope = 'DebugService'}) {
    debugLog('$label cache hit', scope: scope);
  }
  
  void log(String message);
  
  Widget buildOverlay({
    required Size parentSize,
    required double totalCoverage,
    required double textCoverage,
    required double totalThreshold,
    required double textThreshold,
    String? targetText,
  });

  void drawDebugRect(Canvas canvas, Rect rect, Paint paint);
  
  bool shouldShowHitGrids();
}
