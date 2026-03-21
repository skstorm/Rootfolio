import 'dart:io';
import '../../../core/utils/result.dart';
import 'image_analysis.dart';
import 'title_result.dart';

abstract class TitleRepository {
  /// 이미지를 분석하여 텍스트 태그 목록 추출
  Future<Result<ImageAnalysis>> analyzeImage(
    File image, {
    bool useCache = true,
  });
  
  /// 추출된 태그와 사용자 프리셋을 바탕으로 자막 문장 생성
  Future<Result<TitleResult>> generateTitle({
    required List<String> tags,
    required String styleId,
    List<String> recentTitles = const [],
    String? llmModel,
  });

  /// 이미지 분석과 LLM 제목 생성을 순차적으로 수행합니다.
  Future<Result<TitleResult>> generateTitleFromImage({
    required File image,
    required String styleId,
    bool useCache = true,
    String? llmModel,
  });
}
