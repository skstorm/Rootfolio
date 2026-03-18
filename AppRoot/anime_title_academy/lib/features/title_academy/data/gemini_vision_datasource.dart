import 'dart:io';

import '../../../core/network/ai_client.dart';
import 'vision_response_model.dart';
import 'package:injectable/injectable.dart';
import 'image_payload_preparer.dart';

@injectable
class GeminiVisionDatasource {
  final AiClient _aiClient;
  final ImagePayloadPreparer _payloadPreparer;

  GeminiVisionDatasource(this._aiClient, this._payloadPreparer);

  Future<VisionResponseModel> analyzeImage(File image) async {
    const prompt = '이 이미지의 핵심 객체, 배경, 분위기, 행동 양상을 5~10개의 쉼표로 구분된 키워드로만 추출해줘. 친절한 서술이나 인사말 없이 키워드만 줘.';
    
    try {
      final preparedImage = await _payloadPreparer.prepare(image);
      final responseText = await _aiClient.analyzeImage(preparedImage, prompt);
      
      // 쉼표 단위로 태그 분리 및 공백 제거
      final tags = responseText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
          
      return VisionResponseModel(extractedTags: tags.isEmpty ? ['분석 실패'] : tags);
    } catch (e) {
      throw Exception('비전 API 분석 중 오류 발생: $e');
    }
  }
}
