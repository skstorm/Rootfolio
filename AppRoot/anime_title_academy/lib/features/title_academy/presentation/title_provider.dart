import 'dart:io';

import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/core/config/app_runtime_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../di/injection_container.dart';
import '../../share_kit/domain/share_service.dart';
import '../data/prompt_template_service.dart';
import '../domain/analyze_image.dart';
import '../domain/generate_title.dart';
import '../domain/image_analysis.dart';
import '../domain/title_generation_model.dart';
import '../domain/title_usage_quota_service.dart';
import '../domain/title_usage_quota_snapshot.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';
import '../domain/quota_gated_pipeline_usecase.dart';
import '../../watermark/domain/composite_title.dart';
import '../../watermark/domain/watermark_repository.dart';

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

enum TitleLoadingMode {
  fullPipeline,
  regenerateOnly,
}

class TitleLoadingModeNotifier extends Notifier<TitleLoadingMode?> {
  @override
  TitleLoadingMode? build() => null;

  void set(TitleLoadingMode mode) => state = mode;

  void clear() => state = null;
}

final titleLoggerProvider = Provider<AppLogger>((ref) => getIt<AppLogger>());
final promptTemplateServiceProvider =
    Provider<PromptTemplateService>((ref) => getIt<PromptTemplateService>());
final titleRepositoryProvider =
    Provider<TitleRepository>((ref) => getIt<TitleRepository>());
final watermarkRepositoryProvider =
    Provider<WatermarkRepository>((ref) => getIt<WatermarkRepository>());
final compositeTitleUseCaseProvider = Provider<CompositeTitleUseCase>((ref) {
  return CompositeTitleUseCase(ref.read(watermarkRepositoryProvider));
});
final shareServiceProvider =
    Provider<ShareService>((ref) => getIt<ShareService>());
final appRuntimeConfigProvider =
    Provider<AppRuntimeConfig>((ref) => getIt<AppRuntimeConfig>());
final adServiceProvider = Provider<AdService>((ref) => getIt<AdService>());
final titleUsageQuotaServiceProvider =
    Provider<TitleUsageQuotaService>((ref) => getIt<TitleUsageQuotaService>());
final titleQuotaProvider = FutureProvider<TitleUsageQuotaSnapshot>((ref) async {
  final service = ref.read(titleUsageQuotaServiceProvider);
  return service.getQuota();
});
final quotaGatedPipelineProvider = Provider<QuotaGatedPipelineUseCase>((ref) {
  return QuotaGatedPipelineUseCase(
    quotaService: ref.read(titleUsageQuotaServiceProvider),
    adService: ref.read(adServiceProvider),
  );
});

final titleNotifierProvider =
    AsyncNotifierProvider<TitleNotifier, TitleViewState?>(TitleNotifier.new);
final titleLoadingModeProvider =
    NotifierProvider<TitleLoadingModeNotifier, TitleLoadingMode?>(
      TitleLoadingModeNotifier.new,
    );

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
    TitleGenerationModel llmModel = TitleGenerationModel.fast,
  }) async {
    ref.read(titleLoadingModeProvider.notifier).set(TitleLoadingMode.fullPipeline);
    state = const AsyncLoading();

    try {
      final analysis = await _analyzeImage(image, useCache: useCache);
      if (analysis is Failure<ImageAnalysis>) {
        ref.read(titleLoadingModeProvider.notifier).clear();
        state = AsyncError(analysis.failure.message, StackTrace.current);
        return;
      }

      final tags = (analysis as Success<ImageAnalysis>).data.tags;
      final title = await _generateTitle(
        tags: tags,
        styleId: styleId,
        recentTitles: recentTitles,
        llmModel: llmModel.modelName,
      );
      if (title is Failure<TitleResult>) {
        ref.read(titleLoadingModeProvider.notifier).clear();
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
      ref.read(titleLoadingModeProvider.notifier).clear();
    } catch (error, stackTrace) {
      ref.read(titleLoadingModeProvider.notifier).clear();
      _logger.error(
        'Unexpected title pipeline error',
        error: error,
        stackTrace: stackTrace,
        name: 'TitleNotifier',
      );
      state = AsyncError('AI 처리 중 예기치 못한 오류가 발생했습니다: $error', stackTrace);
    }
  }

  Future<void> regenerateTitleOnly({
    TitleGenerationModel llmModel = TitleGenerationModel.fast,
  }) async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    ref.read(titleLoadingModeProvider.notifier).set(TitleLoadingMode.regenerateOnly);
    state = const AsyncLoading();
    try {
      final title = await _generateTitle(
        tags: current.tags,
        styleId: current.styleId,
        recentTitles: current.recentTitles,
        llmModel: llmModel.modelName,
      );
      if (title is Failure<TitleResult>) {
        ref.read(titleLoadingModeProvider.notifier).clear();
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
      ref.read(titleLoadingModeProvider.notifier).clear();
    } catch (error, stackTrace) {
      ref.read(titleLoadingModeProvider.notifier).clear();
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
