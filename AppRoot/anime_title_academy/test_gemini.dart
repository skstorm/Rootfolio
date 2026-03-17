import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void main() async {
  // API 키 직접 기입 (디버그용)
  // API 키 직접 기입 대신 환경변수나 .env를 사용해야 합니다.
  final apiKey = 'REMOVED_FOR_SECURITY';
  
  print('--- Gemini Model Diagnostics ---');
  
  final client = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  
  try {
    print('Testing [gemini-1.5-flash]...');
    final response = await client.generateContent([Content.text('Hello')]);
    print('✅ gemini-1.5-flash: Success! -> ${response.text}');
  } catch (e) {
    print('❌ gemini-1.5-flash: Failed -> $e');
  }

  try {
    print('Testing [gemini-1.5-flash-latest]...');
    final client2 = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    final response = await client2.generateContent([Content.text('Hello')]);
    print('✅ gemini-1.5-flash-latest: Success! -> ${response.text}');
  } catch (e) {
    print('❌ gemini-1.5-flash-latest: Failed -> $e');
  }

  try {
    print('Testing [gemini-2.0-flash]...');
    final client3 = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    final response = await client3.generateContent([Content.text('Hello')]);
    print('✅ gemini-2.0-flash: Success! -> ${response.text}');
  } catch (e) {
    print('❌ gemini-2.0-flash: Failed -> $e');
  }
}
