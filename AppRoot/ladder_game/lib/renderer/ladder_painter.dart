import 'package:flutter/material.dart';
import '../models/ladder_models.dart';

class LadderPainter extends CustomPainter {
  final LadderMap map;
  final List<List<Offset>> activePaths;
  final Color themeColor;
  final Offset? currentPlayerPos; // 현재 애니메이션 중인 플레이어 위치

  LadderPainter({
    required this.map,
    required this.activePaths,
    required this.themeColor,
    this.currentPlayerPos,
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
    if (currentPlayerPos != null) {
      final path = activePaths.first;
      if (path.isNotEmpty) {
        final pathPainter = Path();
        pathPainter.moveTo(startX + (path[0].dx * colWidth), path[0].dy * height);
        
        bool foundCurrent = false;
        for (int i = 1; i < path.length; i++) {
          // 캐릭터가 이미 지나온 경로는 전체를 그리고, 현재 위치까지만 그림
          Offset p = Offset(startX + (path[i].dx * colWidth), path[i].dy * height);
          
          // 현재 위치가 이 세그먼트 사이에 있는지 대략적으로 체크 (또는 지나왔는지)
          // 여기서는 단순하게 currentPos의 y값을 기준으로 그림
          if (path[i].dy * height <= currentPlayerPos!.dy * height + 1.0) {
             pathPainter.lineTo(p.dx, p.dy);
          } else {
             // 현재 위치까지만 긋기
             pathPainter.lineTo(startX + (currentPlayerPos!.dx * colWidth), currentPlayerPos!.dy * height);
             foundCurrent = true;
             break;
          }
        }
        
        if (!foundCurrent) {
           pathPainter.lineTo(startX + (currentPlayerPos!.dx * colWidth), currentPlayerPos!.dy * height);
        }

        canvas.drawPath(pathPainter, glowPaint);
        canvas.drawPath(pathPainter, accentPaint);

        // 캐릭터 (전동 뿌리 효과)
        canvas.drawCircle(
          Offset(startX + (currentPlayerPos!.dx * colWidth), currentPlayerPos!.dy * height),
          6.0,
          Paint()..color = themeColor..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0)
        );
        canvas.drawCircle(
          Offset(startX + (currentPlayerPos!.dx * colWidth), currentPlayerPos!.dy * height),
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
