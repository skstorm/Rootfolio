import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 디버그 서비스 인터페이스
abstract class DebugService {
  bool get isDebugMode;
  
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

/// 개발 모드용 디버그 서비스 구현체
class DevelopmentDebugService implements DebugService {
  @override
  bool get isDebugMode => true;

  @override
  void log(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
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
      // [REFIX] 스크래치 영역과 겹치지 않도록 더 위로 올림
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
  bool shouldShowHitGrids() => true;
}

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

/// 디버그 서비스 프로바이더
final debugServiceProvider = Provider<DebugService>((ref) {
  if (kDebugMode) {
    return DevelopmentDebugService();
  } else {
    return ReleaseDebugService();
  }
});
