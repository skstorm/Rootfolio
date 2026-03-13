import 'dart:io';
import '../../../core/utils/result.dart';
import '../domain/image_gen_repository.dart';
import '../domain/transformed_image.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ImageGenRepository, env: ['dev'])
class MockImageGenRepository implements ImageGenRepository {
  @override
  List<String> get availableStyles => ['anime', 'pixel_art', 'watercolor'];

  @override
  Future<Result<TransformedImage>> transformImage({
    required File source,
    required String stylePrompt,
  }) async {
    // Mock: 원본 그대로 반환
    await Future.delayed(const Duration(milliseconds: 300));
    return Success(TransformedImage(file: source, style: stylePrompt, isOriginal: true));
  }
}
