import 'package:flutter/material.dart';
import 'scratch_painter.dart';

class ScratchCanvas extends StatefulWidget {
  final Widget child; // 가려질 대상 (원본 이미지)
  final double strokeWidth;
  final VoidCallback? onCleared; // 오토 클리어 임계값 도달 시
  final double clearThreshold; // 예: 0.4 (40%)
  
  const ScratchCanvas({
    super.key,
    required this.child,
    this.strokeWidth = 50.0,
    this.onCleared,
    this.clearThreshold = 0.4,
  });

  @override
  State<ScratchCanvas> createState() => _ScratchCanvasState();
}

class _ScratchCanvasState extends State<ScratchCanvas> {
  List<Offset?> _points = [];
  bool _isCleared = false;
  final GlobalKey _key = GlobalKey();

  void _addPoint(PointerEvent event) {
    if (_isCleared) return;
    final RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(event.position);
      if (mounted) setState(() => _points.add(localPosition));
      _checkClearThreshold(renderBox.size);
    }
  }

  void _checkClearThreshold(Size size) {
    // 간이 임계값 계산 로직: 포인트 개수로 근사치 계산 (퍼포먼스 고려)
    // 실제 픽셀 검사는 무거우므로 화면 너비/높이 대비 포인트 개수로 대략적인 비율 판단
    final maxExpectedPoints = (size.width * size.height) / (widget.strokeWidth * widget.strokeWidth * 0.5);
    final coverageInfo = _points.where((p) => p != null).length / maxExpectedPoints;

    if (coverageInfo >= widget.clearThreshold && !_isCleared) {
      _isCleared = true;
      widget.onCleared?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isCleared 
      ? const SizedBox.shrink() // 클리어 되면 가림막 완전히 제거
      : Listener(
          onPointerDown: (event) {
            _addPoint(event);
          },
          onPointerMove: (event) {
            _addPoint(event);
          },
          onPointerUp: (event) {
            if (mounted) setState(() => _points.add(null));
          },
          child: RepaintBoundary(
            key: _key,
            child: CustomPaint(
              foregroundPainter: ScratchPainter(
                points: _points,
                strokeWidth: widget.strokeWidth,
              ),
              child: widget.child, // 이 자식은 ScratchPainter의 blendMode.clear 때문에 지워진 영역이 투명해짐
            ),
          ),
        );
  }
}
