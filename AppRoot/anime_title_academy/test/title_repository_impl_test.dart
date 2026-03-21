import 'dart:io';
import 'dart:typed_data';

import 'package:anime_title_academy/core/logging/app_logger.dart';
import 'package:anime_title_academy/core/network/ai_client.dart';
import 'package:anime_title_academy/core/utils/result.dart';
import 'package:anime_title_academy/features/title_academy/data/gemini_llm_datasource.dart';
import 'package:anime_title_academy/features/title_academy/data/gemini_vision_datasource.dart';
import 'package:anime_title_academy/features/title_academy/data/image_analysis_cache.dart';
import 'package:anime_title_academy/features/title_academy/data/image_payload_preparer.dart';
import 'package:anime_title_academy/features/title_academy/data/llm_response_model.dart';
import 'package:anime_title_academy/features/title_academy/data/prompt_template_service.dart';
import 'package:anime_title_academy/features/title_academy/data/title_repository_impl.dart';
import 'package:anime_title_academy/features/title_academy/data/vision_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeVisionDatasource extends GeminiVisionDatasource {
  _FakeVisionDatasource(this._handler)
      : super(
          _FakeAiClient(),
          _NoopImagePayloadPreparer(),
          ImageAnalysisCache(),
          AppLogger(),
        );

  final Future<VisionResponseModel> Function(File image) _handler;

  @override
  Future<VisionResponseModel> analyzeImage(
    File image, {
    bool useCache = true,
  }) => _handler(image);
}

class _FakeLlmDatasource extends GeminiLlmDatasource {
  _FakeLlmDatasource(this._handler) : super(_FakeAiClient());

  final Future<LlmResponseModel> Function(String prompt) _handler;

  @override
  Future<LlmResponseModel> generateTitleText(
    String prompt, {
    String? model,
  }) => _handler(prompt);
}

class _FakeAiClient implements AiClient {
  @override
  Future<String> analyzeImage(Uint8List imageBytes, String prompt) {
    throw UnimplementedError();
  }

  @override
  Future<String> generateText(String prompt, {String? model}) {
    throw UnimplementedError();
  }
}

class _NoopImagePayloadPreparer extends ImagePayloadPreparer {
  @override
  Future<Uint8List> prepare(File source) async => Uint8List(0);
}

void main() {
  group('TitleRepositoryImpl', () {
    final logger = AppLogger();
    final promptService = PromptTemplateService();

    test('runs vision then llm and returns success', () async {
      final repository = TitleRepositoryImpl(
        _FakeVisionDatasource((_) async => const VisionResponseModel(extractedTags: ['학교', '노을'])),
        _FakeLlmDatasource((prompt) async {
          expect(prompt, contains('학교'));
          return const LlmResponseModel(title: '노을 아래 너와 나');
        }),
        promptService,
        logger,
      );

      final result = await repository.generateTitleFromImage(
        image: File('fake.jpg'),
        styleId: 'youth',
      );

      expect(result, isA<Success>());
    });

    test('returns failure when llm generation throws', () async {
      final repository = TitleRepositoryImpl(
        _FakeVisionDatasource((_) async => const VisionResponseModel(extractedTags: ['학교'])),
        _FakeLlmDatasource((_) async => throw Exception('llm failed')),
        promptService,
        logger,
      );

      final result = await repository.generateTitleFromImage(
        image: File('fake.jpg'),
        styleId: 'youth',
      );

      expect(result, isA<Failure>());
    });
  });
}
