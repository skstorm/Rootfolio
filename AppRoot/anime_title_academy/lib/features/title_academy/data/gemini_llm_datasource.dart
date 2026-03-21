import '../../../core/network/ai_client.dart';
import 'llm_response_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeminiLlmDatasource {
  final AiClient _aiClient;

  GeminiLlmDatasource(this._aiClient);

  Future<LlmResponseModel> generateTitleText(
    String prompt, {
    String? model,
  }) async {
    try {
      final responseText = await _aiClient.generateText(prompt, model: model);
      return LlmResponseModel(title: responseText.trim().replaceAll('"', ''));
    } catch (e) {
      throw Exception('LLM 자막 생성 중 오류가 발생했습니다: $e');
    }
  }
}
