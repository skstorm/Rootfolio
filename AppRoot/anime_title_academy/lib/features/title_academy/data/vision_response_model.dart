class VisionResponseModel {
  final List<String> extractedTags;

  const VisionResponseModel({required this.extractedTags});

  factory VisionResponseModel.fromJson(Map<String, dynamic> json) {
    // TODO: 실제 Gemini Vision API 응답 규격에 맞게 파싱
    final tags = (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return VisionResponseModel(extractedTags: tags);
  }
}
