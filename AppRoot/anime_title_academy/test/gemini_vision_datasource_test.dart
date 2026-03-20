import 'dart:io';
import 'dart:typed_data';

import 'package:anime_title_academy/core/logging/app_logger.dart';
import 'package:anime_title_academy/core/network/ai_client.dart';
import 'package:anime_title_academy/features/title_academy/data/gemini_vision_datasource.dart';
import 'package:anime_title_academy/features/title_academy/data/image_analysis_cache.dart';
import 'package:anime_title_academy/features/title_academy/data/image_payload_preparer.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingAiClient implements AiClient {
  int analyzeCalls = 0;

  @override
  Future<String> analyzeImage(Uint8List imageBytes, String prompt) async {
    analyzeCalls++;
    return '학교, 노을';
  }

  @override
  Future<String> generateText(String prompt) {
    throw UnimplementedError();
  }
}

class _FixedPayloadPreparer extends ImagePayloadPreparer {
  @override
  Future<String> buildCacheKey(File source) async => 'same-image';

  @override
  Future<Uint8List> prepare(File source) async => Uint8List.fromList([1, 2, 3]);
}

void main() {
  test('reuses cached vision analysis for repeated image requests', () async {
    final client = _CountingAiClient();
    final datasource = GeminiVisionDatasource(
      client,
      _FixedPayloadPreparer(),
      ImageAnalysisCache(),
      AppLogger(),
    );

    final tempDir = await Directory.systemTemp.createTemp('vision_cache_test');
    final imageFile = File('${tempDir.path}/image.jpg');
    await imageFile.writeAsBytes([1, 2, 3], flush: true);

    await datasource.analyzeImage(imageFile);
    await datasource.analyzeImage(imageFile);

    expect(client.analyzeCalls, 1);
  });
}
