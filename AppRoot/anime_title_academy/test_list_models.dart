import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void main() async {
  final apiKey = 'AIzaSyCuFKKK0MWe-IiLoQqSkN57lKmENMCgX6M';
  print('--- Gemini SDK Model List ---');
  
  // 사실 모델 리스트 조회는 GenerativeModel 인스턴스 없이도 가능하나
  // SDK 구조상 HTTP 클라이언트를 직접 쓰거나, 
  // 지원되지 않는 모델을 넣어 에러 메시지의 'available models' 리스트를 보는 것이 빠를 때가 있음.
  // 하지만 여기서는 확실하게 모든 모델을 테스트해봄.
  
  final testModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-1.0-pro',
    'gemini-pro',
    'gemini-pro-vision',
    'gemini-2.0-flash',
    'gemini-flash-latest'
  ];

  for (var m in testModels) {
    try {
      final model = GenerativeModel(model: m, apiKey: apiKey);
      final response = await model.generateContent([Content.text('hi')]);
      if (response.text != null) {
        print('✅ [MATCHED] $m works!');
      }
    } catch (e) {
      print('❌ [FAILED] $m : ${e.toString().split('\n').first}');
    }
  }
}
