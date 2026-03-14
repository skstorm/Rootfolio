import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scratch_painter.dart';
import 'scratch_provider.dart';

class ScratchCanvas extends ConsumerStatefulWidget {
  final Widget child; // 배경 내용
  final double strokeWidth;
  final double erasureIntensity;
  final BoxDecoration? decoration;
  final String? guideText;
  final TextStyle? guideTextStyle;
  final VoidCallback? onCleared;
  final double clearThreshold;
  
  const ScratchCanvas({
    super.key,
    required this.child,
    this.strokeWidth = 50.0,
    this.erasureIntensity = 0.15,
    this.decoration,
    this.guideText,
    this.guideTextStyle,
    this.onCleared,
    this.clearThreshold = 0.4,
  });

  @override
  ConsumerState<ScratchCanvas> createState() => _ScratchCanvasState();
}

class _ScratchCanvasState extends ConsumerState<ScratchCanvas> {
  List<Offset?> _points = [];
  bool _isCleared = false;
  final GlobalKey _key = GlobalKey();
  final Set<String> _hitGrids = {}; // 긁힌 영역 체크용 (그리드 기반)

  @override
  void didUpdateWidget(covariant ScratchCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final globalIsCleared = ref.read(scratchProvider).isCleared;
    if (!globalIsCleared && _isCleared) {
      if (mounted) {
        setState(() {
          _points = [];
          _hitGrids.clear();
          _isCleared = false;
        });
      }
    }
  }

  void _addPoint(PointerEvent event) {
    if (_isCleared) return;
    final RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(event.position);
      if (mounted) {
        setState(() {
          _points.add(localPosition);
          // 그리드 기반 중복 제거 면적 계산 (10x10 픽셀 단위)
          final gridX = (localPosition.dx / 10).floor();
          final gridY = (localPosition.dy / 10).floor();
          _hitGrids.add('$gridX,$gridY');
        });
      }
      _checkClearThreshold(renderBox.size);
    }
  }

  void _checkClearThreshold(Size size) {
    // 실제 전체 그리드 개수 대비 긁힌 그리드 개수로 비율 계산
    final totalGrids = (size.width / 10) * (size.height / 10);
    final coverageInfo = _hitGrids.length / totalGrids;

    // 점진적 스크래치이므로 임계값 도달 시 클리어 처리
    // 사용자가 '충분히 긁었다'고 느낄 수 있도록 임계값을 조절 가능하게 함 (기본 0.4)
    if (coverageInfo >= widget.clearThreshold && !_isCleared) {
      if (mounted) {
        setState(() {
          _isCleared = true;
        });
      }
      widget.onCleared?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalIsCleared = ref.watch(scratchProvider).isCleared;
    if (!globalIsCleared && _isCleared) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isCleared) {
          setState(() {
            _points = [];
            _hitGrids.clear();
            _isCleared = false;
          });
        }
      });
    }

    return Listener(
      onPointerDown: _addPoint,
      onPointerMove: _addPoint,
      onPointerUp: (event) {
        if (mounted) setState(() => _points.add(null));
      },
      child: RepaintBoundary(
        key: _key,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            CustomPaint(
              painter: ScratchPainter(
                points: _points,
                strokeWidth: widget.strokeWidth,
                erasureIntensity: widget.erasureIntensity,
                decoration: widget.decoration,
                guideText: widget.guideText,
                guideTextStyle: widget.guideTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
