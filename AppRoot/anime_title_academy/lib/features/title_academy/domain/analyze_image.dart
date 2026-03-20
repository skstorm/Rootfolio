import 'dart:io';
import '../../../core/utils/result.dart';
import 'image_analysis.dart';
import 'title_repository.dart';

class AnalyzeImageUseCase {
  final TitleRepository _repository;

  AnalyzeImageUseCase(this._repository);

  Future<Result<ImageAnalysis>> call(File image, {bool useCache = true}) async {
    return await _repository.analyzeImage(image, useCache: useCache);
  }
}
