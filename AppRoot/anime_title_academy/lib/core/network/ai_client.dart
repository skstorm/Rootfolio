import 'dart:typed_data';

abstract class AiClient {
  /// 프롬프트를 바탕으로 텍스트를 생성합니다.
  Future<String> generateText(String prompt);

  /// 이미지와 프롬프트를 바탕으로 분석 텍스트를 반환합니다.
  Future<String> analyzeImage(Uint8List imageBytes, String prompt);
}
