import 'dart:io';
import '../../../core/utils/result.dart';
import 'transformed_image.dart';

abstract class ImageGenRepository {
  /// 이미지를 지정된 스타일로 AI 변환
  Future<Result<TransformedImage>> transformImage({
    required File source,
    required String stylePrompt,
  });

  /// 지원 가능한 스타일 목록
  List<String> get availableStyles;
}
