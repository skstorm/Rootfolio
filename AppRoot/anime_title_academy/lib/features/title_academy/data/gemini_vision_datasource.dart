import 'dart:io';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/ai_client.dart';
import 'package:injectable/injectable.dart';
import 'image_analysis_cache.dart';
import 'image_payload_preparer.dart';
import 'vision_response_model.dart';

@injectable
class GeminiVisionDatasource {
  final AiClient _aiClient;
  final ImagePayloadPreparer _payloadPreparer;
  final ImageAnalysisCache _cache;
  final AppLogger _logger;

  GeminiVisionDatasource(
    this._aiClient,
    this._payloadPreparer,
    this._cache,
    this._logger,
  );

  Future<VisionResponseModel> analyzeImage(File image) async {
    const prompt = '이 이미지의 핵심 객체, 배경, 분위기, 행동 양상을 5~10개의 쉼표로 구분된 키워드로만 추출해줘. 친절한 서술이나 인사말 없이 키워드만 줘.';
    
    try {
      final cacheKey = await _payloadPreparer.buildCacheKey(image);
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        _logger.debug('Vision analysis cache hit', name: 'GeminiVisionDatasource');
        return cached;
      }

      final preparedImageBytes = await _payloadPreparer.prepare(image);
      final responseText = await _aiClient.analyzeImage(preparedImageBytes, prompt);
      
      // 쉼표 단위로 태그 분리 및 공백 제거
      final tags = responseText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final result = VisionResponseModel(
        extractedTags: tags.isEmpty ? ['분석 실패'] : tags,
      );
      _cache.put(cacheKey, result);
      return result;
    } catch (e) {
      throw Exception('비전 API 분석 중 오류 발생: $e');
    }
  }
}
