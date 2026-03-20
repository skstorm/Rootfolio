import 'dart:math';

import 'package:injectable/injectable.dart';
import '../../../core/constants/ui_constants.dart';
import '../domain/prompt_template.dart';

@lazySingleton
class PromptTemplateService {
  /// 모든 장르에 공통으로 적용되는 제약 사항
  String get commonConstraints => """
[공통 제약 사항]
1. 반드시 한국어로 답변할 것.
2. 친절한 인사말이나 부연 설명 없이 오직 '제목' 텍스트만 출력할 것.
3. 공백을 포함하여 반드시 ${UiConstants.maxTitleLength}자 이내로 작성할 것 (매우 중요).
4. 불필요한 따옴표(")는 제거할 것.
""";

  final Map<String, PromptTemplate> _templates = {
    'youth': const PromptTemplate(
      persona: "너는 신카이 마코토 감독의 애니메이션을 집필하는 서정적인 시나리오 작가야.",
      styleInstructions: "투명하고 맑은 사춘기 청춘의 감성을 담아줘. 아련한 첫사랑이나 일상의 소중함을 시적인 문장으로 표현해.",
      examples: [
        "그날의 바람은 너의 향기를 닮아 있었다",
        "우리가 엇갈린 5센티미터의 거리",
        "비 오는 오후, 이름 모를 정원에서 너를 기다려",
      ],
    ),
    'isekai': const PromptTemplate(
      persona: "너는 요즘 유행하는 일본 라이트노벨(이세계물) 전문 작가야.",
      styleInstructions: "제목만 읽어도 내용을 다 알 수 있을 정도로 구구절절하고 황당한 서술형 제목을 만들어줘. 어이없을수록 좋아.",
      constraints: "문장이 길어지더라도 핵심 키워드를 포함해.",
      examples: [
        "만렙 용사였던 내가 알고 보니 편의점 알바생?!",
        "전생했더니 슬라임이 되어버린 건에 대하여",
        "옆자리 미소녀가 사실은 마왕군 간부라는데 어쩌지",
      ],
    ),
    'battle': const PromptTemplate(
      persona: "너는 90년대 소년 점프 스타일의 열혈 액션 만화 작가야.",
      styleInstructions: "비장미 넘치고 강렬한 외침 같은 제목을 만들어줘. 마치 기술명을 외치는 듯한 느낌이나 절체절명의 위기감을 강조해.",
      examples: [
        "폭발하는 영혼! 최후의 일격을 날려라!",
        "깨어나는 흑염룡, 내 봉인된 오른팔의 힘",
        "결전! 우주의 운명을 건 마지막 승부",
      ],
    ),
  };

  /// 이미지를 직접 분석하여 자막을 생성할 때 사용하는 프롬프트입니다.
  String generateOneShotPrompt(String styleId) {
    final template = _templates[styleId] ?? _templates['youth']!;
    
    return """
다음 이미지를 분석하고, 그 결과와 아래의 [지침]을 결합하여 최적의 애니메이션 자막(제목)을 하나만 생성해줘.

${template.toFullPrompt(commonConstraints)}
""".trim();
  }

  /// 특정 장르와 분석된 태그를 조합하여 프롬프트를 생성합니다 (샌드박스용).
  String generatePrompt(String styleId, String imageAnalysisTags) {
    final template = _templates[styleId] ?? _templates['youth']!;
    
    return """
이미지 분석 결과($imageAnalysisTags)를 바탕으로 다음 지침에 따라 제목을 만들어줘.

${template.toFullPrompt(commonConstraints)}
""".trim();
  }

  /// 추출된 태그와 스타일 지침을 결합하여 LLM용 프롬프트를 생성합니다 (Two-step용).
  String generateLlmPrompt(
    String styleId,
    List<String> tags, {
    List<String> recentTitles = const [],
  }) {
    final template = _templates[styleId] ?? _templates['youth']!;
    final focusTags = _pickFocusTags(tags);
    final tagsString = tags.join(', ');
    final focusTagsString = focusTags.join(', ');
    final recentTitlesText = recentTitles.isEmpty
        ? ''
        : """

[직전 생성 제목]
${recentTitles.map((title) => '- $title').join('\n')}

[다양성 규칙]
- 위 제목들과 같은 핵심 단어, 문장 구조, 감정 톤을 최대한 반복하지 말 것.
- 직전 제목들과 겹치지 않는 새로운 표현으로 작성할 것.
""";

    return """
이미지에서 다음과 같은 요소들이 분석되었습니다: [$tagsString]
이번 생성에서 우선적으로 반영할 핵심 태그는 [$focusTagsString] 입니다.

이 요소들을 바탕으로 아래의 [지침]을 엄격히 준수하여 최적의 애니메이션 자막(제목)을 하나만 생성해줘.
$recentTitlesText

${template.toFullPrompt(commonConstraints)}
""".trim();
  }

  /// 사용 가능한 스타일 ID 목록을 반환합니다.
  List<String> get availableStyleIds => _templates.keys.toList();

  List<String> _pickFocusTags(List<String> tags) {
    final normalized = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    if (normalized.isEmpty) {
      return const ['감정', '장면'];
    }

    final random = Random();
    normalized.shuffle(random);
    final focusCount = normalized.length == 1 ? 1 : random.nextInt(2) + 1;
    return normalized.take(focusCount).toList();
  }
}
