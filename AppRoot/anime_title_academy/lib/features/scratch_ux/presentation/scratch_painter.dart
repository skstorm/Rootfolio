import 'package:flutter/material.dart';
import '../../../core/debug/debug_service.dart';
import '../../../core/constants/ui_constants.dart';

class ScratchPainter extends CustomPainter {
  final List<Offset?> points;
  final double strokeWidth;
  final double erasureIntensity;
  final BoxDecoration? decoration;
  final String? guideText;
  final TextStyle? guideTextStyle;
  final String? targetText;
  final TextStyle? targetTextStyle;
  final Function(Rect)? onTextRectCalculated;
  final DebugService debugService;

  ScratchPainter({
    required this.points,
    required this.debugService,
    this.strokeWidth = 40.0,
    this.erasureIntensity = 0.15,
    this.decoration,
    this.guideText,
    this.guideTextStyle,
    this.targetText,
    this.targetTextStyle,
    this.onTextRectCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // [SAFETY] 크기가 유효하지 않으면 그리지 않음 (무한대 오류 방지)
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) return;

    // 1. 투명도 지원 레이어 생성 (필수)
    canvas.saveLayer(Offset.zero & size, Paint());

    try {
      // 2. 마스크 배경 (BoxDecoration)
      if (decoration != null) {
        final boxPainter = decoration!.createBoxPainter();
        boxPainter.paint(canvas, Offset.zero, ImageConfiguration(size: size));
      } else {
        canvas.drawRect(Offset.zero & size, Paint()..color = Colors.grey);
      }

      // 3. 안내 문구 (지워질 수 있는 레이어에 위치)
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
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, UiConstants.scratchSoftBlurSigma);

        for (int i = 0; i < points.length - 1; i++) {
          if (points[i] != null && points[i + 1] != null) {
            canvas.drawLine(points[i]!, points[i + 1]!, paint);
          } else if (points[i] != null && points[i + 1] == null) {
            canvas.drawCircle(points[i]!, strokeWidth / 2, paint);
          }
        }
      }

      // 5. 판정 영역 계산 및 [DEBUG] 가시화
      if (targetText != null) {
        final targetPainter = TextPainter(
          text: TextSpan(text: targetText, style: targetTextStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.width);

        final targetOffset = Offset(
          (size.width - targetPainter.width) / 2,
          (size.height - targetPainter.height) / 2,
        );

        final textRect = Rect.fromLTWH(
          targetOffset.dx,
          targetOffset.dy,
          targetPainter.width,
          targetPainter.height,
        );

        // 텍스트 영역 Rect 콜백 호출 (Canvas에게 실제 판정 범위를 알림)
        onTextRectCalculated?.call(textRect);

        // [DEBUG] 실제 판정 대상 영역 가시화 (DebugService 위임 및 상태 확인)
        if (debugService.isDebugMode) {
          debugService.drawDebugRect(
            canvas,
            textRect,
            Paint()
              ..color = Colors.red.withOpacity(0.8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
          );
        }
      }
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ScratchPainter oldDelegate) {
    return true; // 점진적 변화를 위해 항상 다시 그림
  }
}
