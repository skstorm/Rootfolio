import 'package:anime_title_academy/core/constants/ai_pipeline_constants.dart';
import 'package:anime_title_academy/features/title_academy/data/prompt_template_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromptTemplateService', () {
    final service = PromptTemplateService();

    test('includes shared constraints and title length rule', () {
      final prompt = service.generateLlmPrompt('youth', ['학교', '노을']);

      expect(prompt, contains('반드시 한국어로 답변할 것'));
      expect(prompt, contains('${AiPipelineConstants.maxTitleLength}자 이내'));
      expect(prompt, contains('[학교, 노을]'));
      expect(prompt, contains('핵심 태그'));
    });

    test('falls back to youth template for unknown style', () {
      final prompt = service.generateLlmPrompt('unknown-style', ['바람']);

      expect(prompt, contains('신카이 마코토'));
    });

    test('includes diversity rule when recent titles are provided', () {
      final prompt = service.generateLlmPrompt(
        'youth',
        ['학교', '노을'],
        recentTitles: const ['노을 아래 너와 나'],
      );

      expect(prompt, contains('[직전 생성 제목]'));
      expect(prompt, contains('다양성 규칙'));
    });
  });
}
