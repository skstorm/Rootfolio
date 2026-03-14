import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scratch_painter.dart';
import 'scratch_provider.dart';

class ScratchCanvas extends ConsumerStatefulWidget {
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
  ConsumerState<ScratchCanvas> createState() => _ScratchCanvasState();
}

class _ScratchCanvasState extends ConsumerState<ScratchCanvas> {
  List<Offset?> _points = [];
  bool _isCleared = false;
  final GlobalKey _key = GlobalKey();

  @override
  void didUpdateWidget(covariant ScratchCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부 Provider 상태가 리셋되면(isCleared가 false가 되면) 로컬 상태도 초기화
    final globalIsCleared = ref.read(scratchProvider).isCleared;
    if (!globalIsCleared && _isCleared) {
      if (mounted) {
        setState(() {
          _points = [];
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
      if (mounted) setState(() => _points.add(localPosition));
      _checkClearThreshold(renderBox.size);
    }
  }

  void _checkClearThreshold(Size size) {
    final maxExpectedPoints = (size.width * size.height) / (widget.strokeWidth * widget.strokeWidth * 0.5);
    final coverageInfo = _points.where((p) => p != null).length / maxExpectedPoints;

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
    // Provider 상태 변화 감시
    final globalIsCleared = ref.watch(scratchProvider).isCleared;
    if (!globalIsCleared && _isCleared) {
      // 빌드 도중에 setState를 호출하는 것을 피하기 위해 콜백 사용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isCleared) {
          setState(() {
            _points = [];
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
      child: AnimatedOpacity(
        opacity: _isCleared ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        child: RepaintBoundary(
          key: _key,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                foregroundPainter: ScratchPainter(
                  points: _points,
                  strokeWidth: widget.strokeWidth,
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
