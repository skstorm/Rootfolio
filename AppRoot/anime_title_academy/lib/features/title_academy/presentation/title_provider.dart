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
    final repo = getIt<TitleRepository>();
    _analyzeUseCase = AnalyzeImageUseCase(repo);
    _generateUseCase = GenerateTitleUseCase(repo);
    return TitleInitial();
  }

  Future<void> runFullPipeline(File image, String presetType, String prompt) async {
    state = TitleLoading();

    // 1. Vision Analysis
    final analysisResult = await _analyzeUseCase(image);
    if (analysisResult is Failure) {
      state = TitleError((analysisResult as Failure).failure.message);
      return;
    }

    final tags = (analysisResult as Success<ImageAnalysis>).data.tags;

    // 2. Text Generation
    final titleResult = await _generateUseCase(
      tags: tags,
      presetType: presetType,
      presetPrompt: prompt,
    );

    if (titleResult is Failure) {
      state = TitleError((titleResult as Failure).failure.message);
      return;
    }

    state = TitleSuccess((titleResult as Success<TitleResult>).data);
  }
}
