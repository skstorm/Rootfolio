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
      top: 5,
      right: 5,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '전체 노출도: ${(totalCoverage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            if (targetText != null)
              Text(
                '텍스트 영역 노출도: ${(textCoverage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.redAccent, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                ),
              ),
            Text(
              '목표: ${(totalThreshold * 100).toInt()}% / ${(textThreshold * 100).toInt()}%',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8),
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
