import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../di/injection_container.dart';
import '../data/prompt_template_service.dart';
import '../domain/analyze_image.dart';
import '../domain/generate_title.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';

class TitleViewState {
  final TitleResult result;
  final List<String> tags;
  final String styleId;
  final List<String> recentTitles;

  const TitleViewState({
    required this.result,
    required this.tags,
    required this.styleId,
    required this.recentTitles,
  });
}

final titleLoggerProvider = Provider<AppLogger>((ref) => getIt<AppLogger>());
final promptTemplateServiceProvider =
    Provider<PromptTemplateService>((ref) => getIt<PromptTemplateService>());
final titleRepositoryProvider =
    Provider<TitleRepository>((ref) => getIt<TitleRepository>());

final titleNotifierProvider =
    AsyncNotifierProvider<TitleNotifier, TitleViewState?>(TitleNotifier.new);

class TitleNotifier extends AsyncNotifier<TitleViewState?> {
  late final AnalyzeImageUseCase _analyzeImage;
  late final GenerateTitleUseCase _generateTitle;
  late final AppLogger _logger;

  @override
  Future<TitleViewState?> build() async {
    final repository = ref.read(titleRepositoryProvider);
    _analyzeImage = AnalyzeImageUseCase(repository);
    _generateTitle = GenerateTitleUseCase(repository);
    _logger = ref.read(titleLoggerProvider);
    return null;
  }

  Future<void> reset() async {
    state = const AsyncData(null);
  }

  Future<void> runFullPipeline(
    File image,
    String styleId, {
    bool useCache = true,
    List<String> recentTitles = const [],
  }) async {
    state = const AsyncLoading();

    try {
      final analysis = await _analyzeImage(image, useCache: useCache);
      if (analysis is Failure<ImageAnalysis>) {
        state = AsyncError(analysis.failure.message, StackTrace.current);
        return;
      }

      final tags = (analysis as Success<ImageAnalysis>).data.tags;
      final title = await _generateTitle(
        tags: tags,
        styleId: styleId,
        recentTitles: recentTitles,
      );
      if (title is Failure<TitleResult>) {
        state = AsyncError(title.failure.message, StackTrace.current);
        return;
      }

      final titleResult = (title as Success<TitleResult>).data;
      state = AsyncData(
        TitleViewState(
          result: titleResult,
          tags: tags,
          styleId: styleId,
          recentTitles: _appendRecentTitle(recentTitles, titleResult.text),
        ),
      );
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

  Future<void> regenerateTitleOnly() async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    state = const AsyncLoading();
    try {
      final title = await _generateTitle(
        tags: current.tags,
        styleId: current.styleId,
        recentTitles: current.recentTitles,
      );
      if (title is Failure<TitleResult>) {
        state = AsyncError(title.failure.message, StackTrace.current);
        return;
      }

      final titleResult = (title as Success<TitleResult>).data;
      state = AsyncData(
        TitleViewState(
          result: titleResult,
          tags: current.tags,
          styleId: current.styleId,
          recentTitles: _appendRecentTitle(current.recentTitles, titleResult.text),
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Regenerate title only failed',
        error: error,
        stackTrace: stackTrace,
        name: 'TitleNotifier',
      );
      state = AsyncError('자막 재생성 중 오류가 발생했습니다: $error', stackTrace);
    }
  }

  List<String> _appendRecentTitle(List<String> currentTitles, String newTitle) {
    final updated = [
      ...currentTitles.where((title) => title != newTitle),
      newTitle,
    ];
    if (updated.length <= 5) {
      return updated;
    }
    return updated.sublist(updated.length - 5);
  }
}
