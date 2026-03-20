import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/util/debug_service.dart';
import '../../../core/utils/result.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';
import 'gemini_llm_datasource.dart';
import 'gemini_vision_datasource.dart';
import 'prompt_template_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TitleRepository)
class TitleRepositoryImpl implements TitleRepository {
  final GeminiVisionDatasource _visionDatasource;
  final GeminiLlmDatasource _llmDatasource;
  final PromptTemplateService _promptService;
  final AppLogger _logger;

  TitleRepositoryImpl(
    this._visionDatasource, 
    this._llmDatasource,
    this._promptService,
    this._logger,
  );

  @override
  Future<Result<ImageAnalysis>> analyzeImage(
    File image, {
    bool useCache = true,
  }) async {
    try {
      final response = await _visionDatasource.analyzeImage(
        image,
        useCache: useCache,
      );
      return Success(ImageAnalysis(tags: response.extractedTags, confidence: 0.9));
    } catch (e) {
      return const Failure(ServerFailure('비전 분석에 실패했습니다.'));
    }
  }

  @override
  Future<Result<TitleResult>> generateTitle({
    required List<String> tags,
    required String styleId,
    List<String> recentTitles = const [],
  }) async {
    try {
      final fullPrompt = _promptService.generateLlmPrompt(
        styleId,
        tags,
        recentTitles: recentTitles,
      );
      final stopwatch = DebugService.startTimer(
        'llm_generation',
        scope: 'TitleRepository',
      );
      final responseText = await _llmDatasource.generateTitleText(fullPrompt);
      DebugService.endTimer(
        'llm_generation',
        stopwatch,
        scope: 'TitleRepository',
        details: 'style=$styleId',
      );
      
      return Success(TitleResult(
        text: responseText.title.trim().replaceAll('"', ''),
        presetType: styleId,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _logger.error('generateTitle failed', error: e, name: 'TitleRepository');
      return const Failure(AIGenerationFailure('자막 생성에 실패했습니다.'));
    }
  }

  @override
  Future<Result<TitleResult>> generateTitleFromImage({
    required File image,
    required String styleId,
    bool useCache = true,
  }) async {
    final totalStopwatch = DebugService.startTimer(
      'title_pipeline_total',
      scope: 'TitleRepository',
    );
    try {
      // 1단계: 이미지 분석 (태그 추출 - Vision 모델)
      final visionStopwatch = DebugService.startTimer(
        'vision_analysis',
        scope: 'TitleRepository',
      );
      final analysis = await analyzeImage(image, useCache: useCache);
      DebugService.endTimer(
        'vision_analysis',
        visionStopwatch,
        scope: 'TitleRepository',
      );

      if (analysis is Failure<ImageAnalysis>) {
        DebugService.endTimer(
          'title_pipeline_total',
          totalStopwatch,
          scope: 'TitleRepository',
          details: 'failed_at=vision',
        );
        return Failure(analysis.failure);
      }
      final tags = (analysis as Success<ImageAnalysis>).data.tags;

      // 2단계: 자막 생성 (LLM 전용 모델)
      final result = await generateTitle(
        tags: tags,
        styleId: styleId,
        recentTitles: const [],
      );
      DebugService.endTimer(
        'title_pipeline_total',
        totalStopwatch,
        scope: 'TitleRepository',
        details: 'style=$styleId',
      );
      return result;
    } catch (e, stack) {
      DebugService.endTimer(
        'title_pipeline_total',
        totalStopwatch,
        scope: 'TitleRepository',
        details: 'failed_with_exception',
      );
      _logger.error(
        'Two-step pipeline failed',
        error: e,
        stackTrace: stack,
        name: 'TitleRepository',
      );
      return Failure(AIGenerationFailure('파이프라인 처리 실패: $e'));
    }
  }
}
