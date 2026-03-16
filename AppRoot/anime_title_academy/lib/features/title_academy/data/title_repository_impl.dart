import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';
import 'gemini_llm_datasource.dart';
import 'gemini_vision_datasource.dart';
import '../../../core/constants/ui_constants.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TitleRepository)
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

  @override
  Future<Result<TitleResult>> generateTitleOneShot({
    required File image,
    required String presetType,
    required String presetPrompt,
  }) async {
    try {
      String styleInstruction;
      if (presetPrompt == 'anime') {
        styleInstruction = "90년대 일본 열혈 소년만화의 제목 같은 비장한 한국어 문장 딱 1개만 만들어줘. (예: 최후의 일격! 불타오르는 내 오른팔!)";
      } else if (presetPrompt == 'pixel_art') {
        styleInstruction = "은혼이나 짱구 극장판 제목같은 뜬금없고 웃긴 병맛 제목 딱 1개만 만들어줘.";
      } else if (presetPrompt == 'watercolor') {
        styleInstruction = "요즘 라이트노벨 특유의 매우 길고 설명충 같으면서도 어이없는 서술형 제목 딱 1개만 한국어로 만들어줘.";
      } else {
        styleInstruction = "이미지의 분위기에 어울리는 창의적인 한국어 제목 1개를 출력해.";
      }

      final fullPrompt = "이 이미지를 분석하고, $styleInstruction 친절한 인사말이나 부연 설명 없이 제목 텍스트만 출력해. [제약] 제목은 반드시 공백 포함 ${UiConstants.maxTitleLength}자 이내로 작성할 것. 너무 긴 제목은 절대 금지.";

      final responseText = await _visionDatasource.aiClient.analyzeImageAndGenerateText(image, fullPrompt);
      
      return Success(TitleResult(
        text: responseText.trim().replaceAll('"', ''),
        presetType: presetType,
        timestamp: DateTime.now(),
      ));
    } catch (e, stack) {
      print('❌ TitleRepositoryImpl.generateTitleOneShot 오류: $e');
      print(stack);
      return const Failure(AIGenerationFailure('통합 자막 생성에 실패했습니다.'));
    }
  }
}
