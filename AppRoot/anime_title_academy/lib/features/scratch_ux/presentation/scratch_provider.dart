import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScratchState {
  final bool isCleared;
  final double percent;
  final int revealEventId;

  const ScratchState({
    this.isCleared = false,
    this.percent = 0.0,
    this.revealEventId = 0,
  });

  ScratchState copyWith({
    bool? isCleared,
    double? percent,
    int? revealEventId,
  }) {
    return ScratchState(
      isCleared: isCleared ?? this.isCleared,
      percent: percent ?? this.percent,
      revealEventId: revealEventId ?? this.revealEventId,
    );
  }
}

class ScratchNotifier extends Notifier<ScratchState> {
  @override
  ScratchState build() => const ScratchState();

  void updatePercent(double newPercent) {
    if (state.isCleared) return;
    state = state.copyWith(percent: newPercent);
  }

  void setCleared() {
    state = state.copyWith(
      isCleared: true,
      percent: 1.0,
      revealEventId: state.revealEventId + 1,
    );
  }

  void reset() {
    // 리셋 시 percent를 잠시 -1.0으로 두어 Canvas가 확실히 변화를 감지하게 함
    state = const ScratchState(isCleared: false, percent: -1.0);
    // 바로 정상 초기값으로 복구
    Future.microtask(() => state = const ScratchState());
  }
}

final scratchProvider = NotifierProvider<ScratchNotifier, ScratchState>(() {
  return ScratchNotifier();
});
