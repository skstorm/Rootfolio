import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../di/injection_container.dart';
import '../data/prompt_template_service.dart';
import '../domain/analyze_image.dart';
import '../domain/generate_title.dart';
import '../domain/run_title_pipeline.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';

final titlePipelineUseCaseProvider = Provider<RunTitlePipelineUseCase>((ref) {
  final repository = getIt<TitleRepository>();
  return RunTitlePipelineUseCase(
    AnalyzeImageUseCase(repository),
    GenerateTitleUseCase(repository),
  );
});

final titleLoggerProvider = Provider<AppLogger>((ref) => getIt<AppLogger>());
final promptTemplateServiceProvider =
    Provider<PromptTemplateService>((ref) => getIt<PromptTemplateService>());
final titleRepositoryProvider =
    Provider<TitleRepository>((ref) => getIt<TitleRepository>());

final titleNotifierProvider =
    AsyncNotifierProvider<TitleNotifier, TitleResult?>(TitleNotifier.new);

class TitleNotifier extends AsyncNotifier<TitleResult?> {
  late final RunTitlePipelineUseCase _pipeline;
  late final AppLogger _logger;

  @override
  Future<TitleResult?> build() async {
    _pipeline = ref.read(titlePipelineUseCaseProvider);
    _logger = ref.read(titleLoggerProvider);
    return null;
  }

  Future<void> reset() async {
    state = const AsyncData(null);
  }

  Future<void> runFullPipeline(File image, String styleId) async {
    state = const AsyncLoading();

    try {
      final result = await _pipeline(image: image, styleId: styleId);
      if (result is Failure<TitleResult>) {
        state = AsyncError(result.failure.message, StackTrace.current);
        return;
      }

      state = AsyncData((result as Success<TitleResult>).data);
    } catch (error, stackTrace) {
      _logger.error(
        'Unexpected title pipeline error',
        error: error,
        stackTrace: stackTrace,
        name: 'TitleNotifier',
      );
      state = AsyncError('AI 처리 중 예기치 못한 오류가 발생했습니다: $error', stackTrace);
    }
  }
}
