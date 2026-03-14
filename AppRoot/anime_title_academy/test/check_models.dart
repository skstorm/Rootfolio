import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  if (apiKey == null) {
    print('Error: API Key not found in .env');
    exit(1);
  }

  print('Listing models for API Key: ${apiKey.substring(0, 5)}...');
  try {
    // google_generative_ai 0.4.7 기준 모델 리스트 조회
    // 0.4.7 버전에서는 GenerativeModel 대신 별도의 클라이언트나 요청이 필요할 수 있음
    // 일단 가장 확실한 방법은 curl을 사용하거나, 
    // 패키지 내부에 모델 리스트 조회 기능이 있는지 확인
    print('Testing common model names...');
    final modelsToTest = [
      'gemini-1.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-pro',
      'gemini-1.5-pro-latest',
      'gemini-pro',
      'gemini-pro-vision'
    ];

    for (var modelName in modelsToTest) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: apiKey);
        // 간단한 텍스트 생성 테스트
        final response = await model.generateContent([Content.text('hi')]);
        print('✅ Model "$modelName" is available and working!');
      } catch (e) {
        print('❌ Model "$modelName" failed: $e');
      }
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}
