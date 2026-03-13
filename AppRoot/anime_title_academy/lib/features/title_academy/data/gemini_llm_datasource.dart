import '../../../core/network/api_client.dart';
import 'llm_response_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeminiLlmDatasource {
  final ApiClient _apiClient;

  GeminiLlmDatasource(this._apiClient);

  Future<LlmResponseModel> generateTitleText(List<String> tags, String presetPrompt) async {
    // TODO: 실제 LLM API 연동 코드로 대체
    await Future.delayed(const Duration(seconds: 1));
    
    // 임시 더미 텍스트
    return LlmResponseModel(title: '생존을 위한 극한의 사투가 시작되었다! (더미)');
  }
}
