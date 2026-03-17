import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/result.dart';
import '../../../di/injection_container.dart';
import '../domain/analyze_image.dart';
import '../domain/generate_title.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';

// Provider Status State
abstract class TitleState {}
class TitleInitial extends TitleState {}
class TitleLoading extends TitleState {}
class TitleSuccess extends TitleState {
  final TitleResult result;
  TitleSuccess(this.result);
}
class TitleError extends TitleState {
  final String message;
  TitleError(this.message);
}

final titleNotifierProvider = NotifierProvider<TitleNotifier, TitleState>(() {
  return TitleNotifier();
});

class TitleNotifier extends Notifier<TitleState> {
  late final AnalyzeImageUseCase _analyzeUseCase;
  late final GenerateTitleUseCase _generateUseCase;

  @override
  TitleState build() {
    return TitleInitial();
  }

  void reset() {
    state = TitleInitial();
  }

  Future<void> runFullPipeline(File image, String presetType, String prompt) async {
    state = TitleLoading();

    try {
      final repo = getIt<TitleRepository>();
      final result = await repo.generateTitleOneShot(
        image: image,
        presetType: presetType,
        presetPrompt: prompt,
      );

      if (result is Failure) {
        state = TitleError((result as Failure).failure.message);
        return;
      }

      state = TitleSuccess((result as Success<TitleResult>).data);
    } catch (e, stack) {
      print('❌ AI 파이프라인 오류: $e');
      print(stack);
      state = TitleError('AI 처리 중 예기치 못한 오류가 발생했습니다: $e');
    }
  }
}
