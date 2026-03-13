import 'dart:io';
import '../../../core/utils/result.dart';
import 'image_gen_repository.dart';
import 'transformed_image.dart';

class TransformImageUseCase {
  final ImageGenRepository _repository;

  TransformImageUseCase(this._repository);

  Future<Result<TransformedImage>> call({
    required File source,
    required String stylePrompt,
  }) async {
    return await _repository.transformImage(
      source: source,
      stylePrompt: stylePrompt,
    );
  }
}
