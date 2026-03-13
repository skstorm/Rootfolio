class LlmResponseModel {
  final String title;

  const LlmResponseModel({required this.title});

  factory LlmResponseModel.fromJson(Map<String, dynamic> json) {
    // TODO: 실제 Gemini/LLM 응답 텍스트 파싱
    return LlmResponseModel(title: json['text'] ?? '제목 생성 오류');
  }
}
