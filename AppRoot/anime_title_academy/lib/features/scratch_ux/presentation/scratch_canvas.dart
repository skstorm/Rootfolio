import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/util/debug_service.dart';
import '../../../core/constants/ui_constants.dart';
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
  final String? targetText;
  final TextStyle? targetTextStyle;
  
  const ScratchCanvas({
    super.key,
    required this.child,
    this.strokeWidth = UiConstants.scratchStrokeWidth,
    this.erasureIntensity = UiConstants.scratchErasureIntensity,
    this.decoration,
    this.guideText,
    this.guideTextStyle,
    this.onCleared,
    this.clearThreshold = UiConstants.scratchTotalClearThreshold,
    this.targetText,
    this.targetTextStyle,
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
    // [MOD] _isCleared 상태여도 포인트를 계속 추가할 수 있게 하여 완료 후에도 긁기 허용
    final RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(event.position);
      
      // 성능 최적화: 이전 포인트와 너무 가까우면(1px 미만) 추가하지 않음
      if (_points.isNotEmpty && _points.last != null) {
        final distance = (localPosition - _points.last!).distance;
        if (distance < 1.0) return;
      }

      if (mounted) {
        setState(() {
          _points.add(localPosition);
          
          // [REFIX] 브러시 반경 내의 모든 그리드를 히트 처리 (시각적 일치성 확보)
          final radius = widget.strokeWidth / 2;
          for (double x = localPosition.dx - radius; x <= localPosition.dx + radius; x += 10) {
            for (double y = localPosition.dy - radius; y <= localPosition.dy + radius; y += 10) {
              final dx = x - localPosition.dx;
              final dy = y - localPosition.dy;
              if (dx * dx + dy * dy <= radius * radius) {
                final gridX = (x / 10).floor();
                final gridY = (y / 10).floor();
                _hitGrids.add('$gridX,$gridY');
              }
            }
          }
        });
      }
      _checkClearThreshold(renderBox.size);
    }
  }

  void _onTextRectCalculated(Rect rect) {
    // [DEBUG] 텍스트 영역 계산 로그 (서비스 사용)
    ref.read(debugServiceProvider).log('Text Rect Calculated: $rect');
  }

  double get _textThreshold => UiConstants.scratchTextClearThreshold;
  
  // [REFIX] 판정 로직 통합: 디버그 출력과 실제 판정이 동일한 수치를 사용하도록 함
  (double total, double text) _calculateCurrentCoverage(Size size) {
    // [SAFETY] 크기가 무한대이거나 비정상적이면 계산하지 않음 (레드박스 방지 핵심)
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) {
      return (0.0, 0.0);
    }

    try {
      // 1. 전체 노출도 계산
      final gridW = (size.width / 10).floor();
      final gridH = (size.height / 10).floor();
      final totalGrids = gridW * gridH;
      final currentTotalCoverage = totalGrids > 0 ? _hitGrids.length / totalGrids : 0.0;

      // 2. 텍스트 영역 노출도 계산
      double currentTextCoverage = 0.0;
      if (widget.targetText != null) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.targetText, style: widget.targetTextStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.width);

        if (textPainter.width.isFinite && textPainter.height.isFinite) {
          final offset = Offset(
            (size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2,
          );

          if (offset.dx.isFinite && offset.dy.isFinite) {
            final rect = Rect.fromLTWH(offset.dx, offset.dy, textPainter.width, textPainter.height);
            
            int textTotalGrids = 0;
            int textHitGrids = 0;

            for (double x = rect.left; x < rect.right; x += 10) {
              for (double y = rect.top; y < rect.bottom; y += 10) {
                textTotalGrids++;
                final gridX = (x / 10).floor();
                final gridY = (y / 10).floor();
                if (_hitGrids.contains('$gridX,$gridY')) {
                  textHitGrids++;
                }
              }
            }
            currentTextCoverage = textTotalGrids > 0 ? textHitGrids / textTotalGrids : 0.0;
          }
        }
      }
      return (currentTotalCoverage, currentTextCoverage);
    } catch (_) {
      return (0.0, 0.0);
    }
  }

  void _checkClearThreshold(Size size) {
    if (_isCleared) return;

    final results = _calculateCurrentCoverage(size);
    final totalCoverage = results.$1;
    final textCoverage = results.$2;

    // 전체 면적 기준(widget.clearThreshold) AND 텍스트 영역 기준(80%) 충족 시 완료
    if (totalCoverage >= widget.clearThreshold && textCoverage >= _textThreshold) {
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
    final debugService = ref.watch(debugServiceProvider);

    // [REFIX] 리셋 버튼 클릭 시 프로바이더 상태 변화를 직접 리스닝하여 로컬 상태 초기화
    ref.listen<ScratchState>(scratchProvider, (previous, next) {
      if (next.percent <= 0.0 && !next.isCleared) {
        if (mounted) {
          setState(() {
            _points = [];
            _hitGrids.clear();
            _isCleared = false;
          });
        }
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        return Listener(
          onPointerDown: _addPoint,
          onPointerMove: _addPoint,
          onPointerUp: (event) {
            if (mounted) setState(() => _points.add(null));
          },
          child: RepaintBoundary(
            key: _key,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                widget.child,
                CustomPaint(
                  painter: ScratchPainter(
                    points: _points,
                    debugService: debugService,
                    strokeWidth: widget.strokeWidth,
                    erasureIntensity: widget.erasureIntensity,
                    decoration: widget.decoration,
                    guideText: widget.guideText,
                    guideTextStyle: widget.guideTextStyle,
                    targetText: widget.targetText,
                    targetTextStyle: widget.targetTextStyle,
                    onTextRectCalculated: _onTextRectCalculated,
                  ),
                ),
                if (debugService.isDebugMode) ...[
                  // [DEBUG] 긁힌 그리드 가시화 (조건부)
                  if (debugService.shouldShowHitGrids())
                    IgnorePointer(
                      child: CustomPaint(
                        size: parentSize,
                        painter: _DebugHitIndicatorPainter(hitGrids: _hitGrids),
                      ),
                    ),
                  
                  // [DEBUG] 수치 오버레이 (위임)
                  debugService.buildOverlay(
                    parentSize: parentSize,
                    totalCoverage: _calculateCurrentCoverage(parentSize).$1,
                    textCoverage: _calculateCurrentCoverage(parentSize).$2,
                    totalThreshold: widget.clearThreshold,
                    textThreshold: _textThreshold,
                    targetText: widget.targetText,
                  ),
                ],
              ],
            ),
          ),
        );
      }
    );
  }
}

class _DebugHitIndicatorPainter extends CustomPainter {
  final Set<String> hitGrids;
  _DebugHitIndicatorPainter({required this.hitGrids});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) return;

    final paint = Paint()..color = Colors.greenAccent.withOpacity(0.5);
    for (final gridKey in hitGrids) {
      final parts = gridKey.split(',');
      if (parts.length == 2) {
        final x = (double.tryParse(parts[0]) ?? 0) * 10 + 5.0;
        final y = (double.tryParse(parts[1]) ?? 0) * 10 + 5.0;
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DebugHitIndicatorPainter oldDelegate) => true;
}
