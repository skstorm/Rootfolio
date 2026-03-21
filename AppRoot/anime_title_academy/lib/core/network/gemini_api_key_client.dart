import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import 'ai_client.dart';

@LazySingleton(as: AiClient)
class GeminiApiKeyClient implements AiClient {
  final AppConfig _config;
  final GenerativeModel _visionModel;
  final GenerativeModel _llmModel;
  final AppLogger _logger;

  GeminiApiKeyClient(this._config, this._logger)
      : _visionModel = GenerativeModel(
          model: _config.visionModel,
          apiKey: _config.geminiApiKey,
        ),
        _llmModel = GenerativeModel(
          model: _config.llmModel,
          apiKey: _config.geminiApiKey,
        ) {
    _logger.info('Gemini API client initialized', name: 'GeminiApiKeyClient');
  }

  @override
  Future<String> generateText(String prompt, {String? model}) async {
    final llmModel = model == null || model == _config.llmModel
        ? _llmModel
        : GenerativeModel(
            model: model,
            apiKey: _config.geminiApiKey,
          );
    final response = await llmModel.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  @override
  Future<String> analyzeImage(Uint8List imageBytes, String prompt) async {
    final imagePart = DataPart('image/jpeg', imageBytes);
    final textPart = TextPart(prompt);

    final response = await _visionModel.generateContent([
      Content.multi([textPart, imagePart])
    ]);
    return response.text ?? '';
  }
}
