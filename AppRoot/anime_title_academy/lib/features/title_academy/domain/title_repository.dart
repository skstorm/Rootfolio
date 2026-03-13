import 'dart:io';
import '../../../core/utils/result.dart';
import 'image_analysis.dart';
import 'title_result.dart';

abstract class TitleRepository {
  /// 이미지를 분석하여 텍스트 태그 목록 추출
  Future<Result<ImageAnalysis>> analyzeVariables(File image);
  
  /// 추출된 태그와 사용자 프리셋을 바탕으로 자막 문장 생성
  Future<Result<TitleResult>> generateTitle({
    required List<String> tags,
    required String presetType,
    required String presetPrompt,
  });
}
