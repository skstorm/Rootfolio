import 'dart:io';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'vision_response_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeminiVisionDatasource {
  final ApiClient _apiClient;

  GeminiVisionDatasource(this._apiClient);

  Future<VisionResponseModel> analyzeImage(File image) async {
    // TODO: 실제 Gemini API 연동 코드로 대체
    // 현재는 더미 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return const VisionResponseModel(
      extractedTags: ['Anime', 'Funny', 'Meme', 'Boy', 'Action'],
    );
  }
}
