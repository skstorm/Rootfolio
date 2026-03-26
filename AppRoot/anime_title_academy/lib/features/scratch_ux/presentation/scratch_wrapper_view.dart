import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/scratch_constants.dart';
import '../../../core/theme/scratch_styles.dart';
import 'reveal_particle.dart';
import 'scratch_canvas.dart';
import 'scratch_provider.dart';

class ScratchWrapperView extends ConsumerWidget {
  final Widget foreground;
  final Widget background;
  final double clearThreshold;
  final double? strokeWidth;
  final double? erasureIntensity;
  final String? targetText;
  final TextStyle? targetTextStyle;

  const ScratchWrapperView({
    super.key,
    required this.foreground,
    required this.background,
    this.clearThreshold = ScratchConstants.totalClearThreshold,
    this.strokeWidth,
    this.erasureIntensity,
    this.targetText,
    this.targetTextStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scratchState = ref.watch(scratchProvider);

    return RevealParticle(
      clipBehavior: Clip.none,
      triggerId: scratchState.revealEventId,
      child: ScratchCanvas(
        strokeWidth: strokeWidth ?? ScratchConstants.strokeWidth,
        erasureIntensity: erasureIntensity ?? ScratchConstants.erasureIntensity,
        clearThreshold: clearThreshold,
        targetText: targetText,
        targetTextStyle: targetTextStyle,
        decoration: ScratchStyles.silverMaskDecoration(0),
        guideText: '여기를 긁어 자막 확인',
        guideTextStyle: ScratchStyles.guideTextStyle,
        onCleared: () {
          ref.read(scratchProvider.notifier).setCleared();
        },
        child: background,
      ),
    );
  }
}
