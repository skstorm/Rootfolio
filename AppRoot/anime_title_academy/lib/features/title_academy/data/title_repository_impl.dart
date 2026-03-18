import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/logging/app_logger.dart';
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
  Future<Result<ImageAnalysis>> analyzeImage(File image) async {
    try {
      final response = await _visionDatasource.analyzeImage(image);
      return Success(ImageAnalysis(tags: response.extractedTags, confidence: 0.9));
    } catch (e) {
      return const Failure(ServerFailure('비전 분석에 실패했습니다.'));
    }
  }

  @override
  Future<Result<TitleResult>> generateTitle({
    required List<String> tags,
    required String styleId,
  }) async {
    try {
      _logger.debug('LLM title generation started for $styleId', name: 'TitleRepository');
      final fullPrompt = _promptService.generateLlmPrompt(styleId, tags);
      
      final stopwatch = Stopwatch()..start();
      final responseText = await _llmDatasource.generateTitleText(fullPrompt);
      stopwatch.stop();
      
      _logger.info(
        'LLM title generation completed in ${stopwatch.elapsedMilliseconds}ms',
        name: 'TitleRepository',
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
  }) async {
    try {
      _logger.info('Two-step title pipeline started', name: 'TitleRepository');
      
      // 1단계: 이미지 분석 (태그 추출 - Vision 모델)
      final visionStopwatch = Stopwatch()..start();
      final analysis = await analyzeImage(image);
      visionStopwatch.stop();
      
      if (analysis is Failure<ImageAnalysis>) return Failure(analysis.failure);
      final tags = (analysis as Success<ImageAnalysis>).data.tags;
      _logger.info(
        'Image analysis completed in ${visionStopwatch.elapsedMilliseconds}ms',
        name: 'TitleRepository',
      );

      // 2단계: 자막 생성 (LLM 전용 모델)
      return await generateTitle(
        tags: tags,
        styleId: styleId,
      );
    } catch (e, stack) {
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
