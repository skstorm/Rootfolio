class PromptTemplate {
  final String persona;
  final String styleInstructions;
  final List<String> examples;
  final String? constraints;

  const PromptTemplate({
    required this.persona,
    required this.styleInstructions,
    required this.examples,
    this.constraints,
  });

  /// 템플릿 정보를 하나의 텍스트 프롬프트로 병합합니다.
  String toFullPrompt(String commonConstraints) {
    final exampleText = examples.isNotEmpty 
        ? "\n[예시]\n${examples.map((e) => "- $e").join('\n')}" 
        : "";
    
    return """
$persona
$styleInstructions
$commonConstraints
${constraints ?? ""}
$exampleText
""".trim();
  }
}
