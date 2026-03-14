import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import 'ai_client.dart';

@LazySingleton(as: AiClient)
class GeminiApiKeyClient implements AiClient {
  final GenerativeModel _visionModel;
  final GenerativeModel _llmModel;

  GeminiApiKeyClient()
      : _visionModel = GenerativeModel(
          model: 'gemini-flash-latest',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        ),
        _llmModel = GenerativeModel(
          model: 'gemini-flash-latest',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        ) {
    if (dotenv.env['GEMINI_API_KEY'] == null) {
      print('⚠️ [GeminiApiKeyClient] GEMINI_API_KEY가 .env 파일에 없습니다!');
    } else {
      print('✅ [GeminiApiKeyClient] Gemini API 클라이언트 초기화 완료');
    }
  }

  @override
  Future<String> generateText(String prompt) async {
    final response = await _llmModel.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  @override
  Future<String> analyzeImage(File image, String prompt) async {
    final bytes = await image.readAsBytes();
    final imagePart = DataPart('image/jpeg', bytes);
    final textPart = TextPart(prompt);

    final response = await _visionModel.generateContent([
      Content.multi([textPart, imagePart])
    ]);
    return response.text ?? '';
  }

  @override
  Future<String> analyzeImageAndGenerateText(File image, String stylePrompt) async {
    try {
      final bytes = await image.readAsBytes();
      print('📸 [Gemini] 이미지 읽기 완료: ${bytes.length} bytes');
      
      final imagePart = DataPart('image/jpeg', bytes);
      final textPart = TextPart(stylePrompt);

      print('🚀 [Gemini] API 호출 시작...');
      final response = await _visionModel.generateContent([
        Content.multi([textPart, imagePart])
      ]);
      
      final text = response.text ?? '';
      print('✅ [Gemini] 응답 수신 성공 (길이: ${text.length})');
      return text;
    } catch (e, stack) {
      print('❌ [Gemini] API 호출 오류: $e');
      print(stack);
      rethrow;
    }
  }
}
