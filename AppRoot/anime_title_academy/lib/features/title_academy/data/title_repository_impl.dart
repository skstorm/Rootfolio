import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';
import 'gemini_llm_datasource.dart';
import 'gemini_vision_datasource.dart';
import 'prompt_template_service.dart';
import '../../../core/constants/ui_constants.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TitleRepository)
class TitleRepositoryImpl implements TitleRepository {
  final GeminiVisionDatasource _visionDatasource;
  final GeminiLlmDatasource _llmDatasource;
  final PromptTemplateService _promptService;

  TitleRepositoryImpl(
    this._visionDatasource, 
    this._llmDatasource,
    this._promptService,
  );

  @override
  Future<Result<ImageAnalysis>> analyzeVariables(File image) async {
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
    required String presetType,
    required String presetPrompt,
  }) async {
    try {
      print('📝 [TitleRepo] LLM 자막 생성 시작 (Style: $presetType)');
      final fullPrompt = _promptService.generateLlmPrompt(presetType, tags);
      
      final stopwatch = Stopwatch()..start();
      final responseText = await _llmDatasource.generateTitleText(tags, fullPrompt);
      stopwatch.stop();
      
      print('✅ [TitleRepo] LLM 응답 수신 (${stopwatch.elapsedMilliseconds}ms): ${responseText.title}');
      
      return Success(TitleResult(
        text: responseText.title.trim().replaceAll('"', ''),
        presetType: presetType,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('❌ [TitleRepo] generateTitle 오류: $e');
      return const Failure(AIGenerationFailure('자막 생성에 실패했습니다.'));
    }
  }

  @override
  Future<Result<TitleResult>> generateTitleOneShot({
    required File image,
    required String presetType,
    required String presetPrompt,
  }) async {
    try {
      print('🚀 [TitleRepo] 투스텝(Two-step) 파이프라인 시작...');
      
      // 1단계: 이미지 분석 (태그 추출 - Vision 모델)
      print('📸 [TitleRepo] 1단계: 이미지 태그 분석 중...');
      final visionStopwatch = Stopwatch()..start();
      final analysis = await analyzeVariables(image);
      visionStopwatch.stop();
      
      if (analysis is Failure) return Failure((analysis as Failure).failure);
      final tags = (analysis as Success<ImageAnalysis>).data.tags;
      print('✅ [TitleRepo] 분석 완료 (${visionStopwatch.elapsedMilliseconds}ms): $tags');

      // 2단계: 자막 생성 (LLM 전용 모델)
      print('✍️ [TitleRepo] 2단계: 자막 문장 생성 중...');
      return await generateTitle(
        tags: tags,
        presetType: presetType,
        presetPrompt: presetPrompt,
      );
    } catch (e, stack) {
      print('❌ [TitleRepo] Two-step 파이프라인 오류: $e');
      print(stack);
      return Failure(AIGenerationFailure('파이프라인 처리 실패: $e'));
    }
  }
}
