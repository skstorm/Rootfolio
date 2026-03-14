import 'dart:io';

abstract class AiClient {
  /// 프롬프트를 바탕으로 텍스트를 생성합니다.
  Future<String> generateText(String prompt);

  /// 이미지와 프롬프트를 바탕으로 분석 텍스트를 반환합니다.
  Future<String> analyzeImage(File image, String prompt);

  /// 이미지와 스타일 프롬프트를 한 번에 보내어 최종 텍스트를 생성합니다. (속도 최적화)
  Future<String> analyzeImageAndGenerateText(File image, String stylePrompt);
}
