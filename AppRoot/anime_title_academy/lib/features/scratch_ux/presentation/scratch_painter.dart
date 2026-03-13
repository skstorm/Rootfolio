import 'package:flutter/material.dart';

class ScratchPainter extends CustomPainter {
  final List<Offset?> points;
  final double strokeWidth;

  ScratchPainter({
    required this.points,
    this.strokeWidth = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Line between points
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        // Point (Tap)
        canvas.drawCircle(points[i]!, strokeWidth / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScratchPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.strokeWidth != strokeWidth;
  }
}
