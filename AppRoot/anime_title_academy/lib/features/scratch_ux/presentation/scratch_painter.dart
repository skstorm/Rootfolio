import 'package:flutter/material.dart';

class ScratchPainter extends CustomPainter {
  final List<Offset?> points;
  final double strokeWidth;
  final double erasureIntensity;
  final BoxDecoration? decoration;
  final String? guideText;
  final TextStyle? guideTextStyle;

  ScratchPainter({
    required this.points,
    this.strokeWidth = 40.0,
    this.erasureIntensity = 0.15,
    this.decoration,
    this.guideText,
    this.guideTextStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 투명도 지원 레이어 생성 (필수)
    canvas.saveLayer(Offset.zero & size, Paint());

    // 2. 마스크 배경 (BoxDecoration)
    if (decoration != null) {
      final boxPainter = decoration!.createBoxPainter();
      boxPainter.paint(canvas, Offset.zero, ImageConfiguration(size: size));
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.grey);
    }

    // 3. 안내 문구
    if (guideText != null) {
      final textPainter = TextPainter(
        text: TextSpan(text: guideText, style: guideTextStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      
      final offset = Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      );
      textPainter.paint(canvas, offset);
    }

    // 4. 점진적 지우기 (dstOut)
    if (points.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.black.withOpacity(erasureIntensity)
        ..blendMode = BlendMode.dstOut
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        } else if (points[i] != null && points[i + 1] == null) {
          canvas.drawCircle(points[i]!, strokeWidth / 2, paint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScratchPainter oldDelegate) {
    return true; // 점진적 변화를 위해 항상 다시 그림
  }
}
