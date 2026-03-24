import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';
import '../logging/app_logger.dart';
import 'debug_service.dart';

/// 개발 모드용 디버그 서비스 구현체
class DevelopmentDebugService implements DebugService {
  final bool isEnabled;

  DevelopmentDebugService({
    required AppLogger logger,
    this.isEnabled = true,
  });

  @override
  bool get isDebugMode => isEnabled;

  @override
  void log(String message) {
    DebugService.debugLog(message);
  }

  @override
  Widget buildOverlay({
    required Size parentSize,
    required double totalCoverage,
    required double textCoverage,
    required double totalThreshold,
    required double textThreshold,
    String? targetText,
  }) {
    return Positioned(
      top: -90, 
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.redAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bug_report, color: Colors.redAccent, size: 12),
                const SizedBox(width: 4),
                Text(
                  'DEBUG INFO',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7), 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 8),
            Text(
              '전체 노출: ${(totalCoverage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            if (targetText != null)
              Text(
                '텍스트 노출: ${(textCoverage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.redAccent, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold
                ),
              ),
            Text(
              '목표: ${(totalThreshold * 100).toInt()}% / ${(textThreshold * 100).toInt()}%',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void drawDebugRect(Canvas canvas, Rect rect, Paint paint) {
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldShowHitGrids() => UiConstants.showDebugHitGrids;
}
