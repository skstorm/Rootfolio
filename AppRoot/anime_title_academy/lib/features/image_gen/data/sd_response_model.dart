import 'dart:convert';

class SdResponseModel {
  final String base64Image; // SD API는 base64 인코딩된 이미지를 반환
  final String? warning;

  const SdResponseModel({required this.base64Image, this.warning});

  factory SdResponseModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    return SdResponseModel(
      base64Image: images?.first as String? ?? '',
      warning: json['info'] as String?,
    );
  }
}
