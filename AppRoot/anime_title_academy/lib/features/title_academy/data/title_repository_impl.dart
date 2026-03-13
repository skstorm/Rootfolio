import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';
import 'gemini_llm_datasource.dart';
import 'gemini_vision_datasource.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TitleRepository, env: ['prod', 'staging'])
class TitleRepositoryImpl implements TitleRepository {
  final GeminiVisionDatasource _visionDatasource;
  final GeminiLlmDatasource _llmDatasource;

  TitleRepositoryImpl(this._visionDatasource, this._llmDatasource);

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
      final response = await _llmDatasource.generateTitleText(tags, presetPrompt);
      return Success(TitleResult(
        text: response.title,
        presetType: presetType,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      return const Failure(AIGenerationFailure('자막 생성에 실패했습니다.'));
    }
  }
}
