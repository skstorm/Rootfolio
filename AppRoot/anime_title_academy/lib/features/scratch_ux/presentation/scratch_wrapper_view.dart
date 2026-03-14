import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reveal_particle.dart';
import 'scratch_canvas.dart';
import 'scratch_provider.dart';

class ScratchWrapperView extends ConsumerWidget {
  final Widget foreground; // 원본 이미지 (가림막)
  final Widget background; // 결과 이미지 (보여질 내용)
  final double clearThreshold;

  const ScratchWrapperView({
    super.key,
    required this.foreground,
    required this.background,
    this.clearThreshold = 0.4,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scratchState = ref.watch(scratchProvider);

    return RevealParticle(
      isTriggered: scratchState.isCleared,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 뒤쪽: 결과 화면
          background,
          
          // 앞쪽: 가림막 + 스크래치 효과
          IgnorePointer(
            ignoring: scratchState.isCleared,
            child: ScratchCanvas(
              strokeWidth: 50.0,
              clearThreshold: clearThreshold,
              onCleared: () {
                ref.read(scratchProvider.notifier).setCleared();
              },
              child: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
