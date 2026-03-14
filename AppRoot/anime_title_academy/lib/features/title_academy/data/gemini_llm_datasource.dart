import '../../../core/network/ai_client.dart';
import 'llm_response_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeminiLlmDatasource {
  final AiClient _aiClient;

  GeminiLlmDatasource(this._aiClient);

  Future<LlmResponseModel> generateTitleText(List<String> tags, String presetPrompt) async {
    final tagsStr = tags.join(', ');
    
    String systemPrompt;
    
    // presetPrompt 에 따라 프롬프트 템플릿 분기
    // HomePage의 styleName 기준 ('anime', 'pixel_art', 'watercolor')
    if (presetPrompt == 'anime') {
      systemPrompt = "주어진 태그($tagsStr)를 사용해서, 90년대 일본 열혈 소년만화의 제목 같은 비장한 한국어 문장 딱 1개만 만들어줘. (예: 최후의 일격! 불타오르는 내 오른팔!) 친절한 인사말이나 부연 설명은 절대 하지 마.";
    } else if (presetPrompt == 'pixel_art') {
      systemPrompt = "주어진 태그($tagsStr)를 사용해서, 은혼이나 짱구 극장판 제목같은 뜬금없고 웃긴 병맛 제목 딱 1개만 만들어줘. 친절한 서술 없이 제목만 말해.";
    } else if (presetPrompt == 'watercolor') {
      systemPrompt = "주어진 태그($tagsStr)를 사용해서, 요즘 라이트노벨 특유의 매우 길고 설명충 같으면서도 어이없는 서술형 제목 딱 1개만 한국어로 만들어줘. 인사말 없이 제목만 출력해.";
    } else {
      systemPrompt = "주어진 태그($tagsStr)를 묘사하는 창의적인 한국어 제목 1개를 출력해. 다른 말은 쓰지 마.";
    }

    try {
      final responseText = await _aiClient.generateText(systemPrompt);
      return LlmResponseModel(title: responseText.trim().replaceAll('"', ''));
    } catch (e) {
      throw Exception('LLM 자막 생성 중 오류가 발생했습니다: $e');
    }
  }
}
