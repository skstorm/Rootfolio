import 'package:flutter/material.dart';
import '../models/ladder_models.dart';

class LadderPainter extends CustomPainter {
  final LadderMap map;
  final List<List<Offset>> activePaths;
  final Color themeColor;
  final double? animationProgress;

  LadderPainter({
    required this.map,
    required this.activePaths,
    required this.themeColor,
    this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double colWidth = size.width / (map.columnCount - 1 + 2);
    final double startX = colWidth;
    final double height = size.height;

    final basePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = themeColor.withOpacity(0.3)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1. 기본 수직선
    for (int i = 0; i < map.columnCount; i++) {
      double x = startX + (i * colWidth);
      canvas.drawLine(Offset(x, 0), Offset(x, height), basePaint);
    }

    // 2. 가로선
    for (int i = 0; i < map.columnCount; i++) {
      double x1 = startX + (i * colWidth);
      for (var point in map.columns[i]) {
        if (point.connectedColumnIndex > i) {
          double x2 = startX + (point.connectedColumnIndex * colWidth);
          double y = point.y * height;
          canvas.drawLine(Offset(x1, y), Offset(x2, y), basePaint);
          canvas.drawCircle(Offset(x1, y), 2.0, accentPaint);
          canvas.drawCircle(Offset(x2, y), 2.0, accentPaint);
        }
      }
    }

    // 3. 현재 진행 중인 경로 실시간 렌더링
    if (animationProgress != null && activePaths.isNotEmpty) {
      final path = activePaths.first;
      if (path.length >= 2) {
        final pathPainter = Path();
        pathPainter.moveTo(startX + (path[0].dx * colWidth), path[0].dy * height);
        
        final int totalSegments = path.length - 1;
        final double currentSegmentProgress = animationProgress! * totalSegments;
        final int fullSegments = currentSegmentProgress.floor();
        final double localProgress = currentSegmentProgress - fullSegments;

        // 1. 이미 지나간 전체 세그먼트 그리기
        for (int i = 1; i <= fullSegments; i++) {
          pathPainter.lineTo(startX + (path[i].dx * colWidth), path[i].dy * height);
        }

        // 2. 현재 진행 중인 세그먼트 일부 그리기
        if (fullSegments < totalSegments) {
          final Offset p1 = path[fullSegments];
          final Offset p2 = path[fullSegments + 1];
          final Offset currentPos = Offset.lerp(p1, p2, localProgress)!;
          pathPainter.lineTo(startX + (currentPos.dx * colWidth), currentPos.dy * height);
        }

        canvas.drawPath(pathPainter, glowPaint);
        canvas.drawPath(pathPainter, accentPaint);

        // 캐릭터 효과 (currentPlayerPos 대신 실시간 계산)
        final Offset p1 = fullSegments < totalSegments ? path[fullSegments] : path.last;
        final Offset p2 = fullSegments < totalSegments ? path[fullSegments + 1] : path.last;
        final Offset curPos = Offset.lerp(p1, p2, fullSegments < totalSegments ? localProgress : 1.0)!;
        final double drawX = startX + (curPos.dx * colWidth);
        final double drawY = curPos.dy * height;

        canvas.drawCircle(
          Offset(drawX, drawY),
          6.0,
          Paint()..color = themeColor..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0)
        );
        canvas.drawCircle(
          Offset(drawX, drawY),
          4.0,
          Paint()..color = Colors.white
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LadderPainter oldDelegate) {
    return true; // 실시간 애니메이션을 위해 항상 리페인트
  }
}
