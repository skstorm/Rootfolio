import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppConfig {
  String get geminiApiKey => _require('GEMINI_API_KEY');

  String get visionModel =>
      dotenv.env['GEMINI_VISION_MODEL']?.trim().isNotEmpty == true
          ? dotenv.env['GEMINI_VISION_MODEL']!.trim()
          : 'gemini-flash-latest';

  String get llmModel =>
      dotenv.env['GEMINI_LLM_MODEL']?.trim().isNotEmpty == true
          ? dotenv.env['GEMINI_LLM_MODEL']!.trim()
          : 'gemini-flash-latest';

  bool get isDebugLoggingEnabled => kDebugMode;

  void validate() {
    geminiApiKey;
  }

  String _require(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }
}
