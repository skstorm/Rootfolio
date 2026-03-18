import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import 'ai_client.dart';

@LazySingleton(as: AiClient)
class GeminiApiKeyClient implements AiClient {
  final GenerativeModel _visionModel;
  final GenerativeModel _llmModel;
  final AppLogger _logger;

  GeminiApiKeyClient(AppConfig config, this._logger)
      : _visionModel = GenerativeModel(
          model: config.visionModel,
          apiKey: config.geminiApiKey,
        ),
        _llmModel = GenerativeModel(
          model: config.llmModel,
          apiKey: config.geminiApiKey,
        ) {
    _logger.info('Gemini API client initialized', name: 'GeminiApiKeyClient');
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
}
