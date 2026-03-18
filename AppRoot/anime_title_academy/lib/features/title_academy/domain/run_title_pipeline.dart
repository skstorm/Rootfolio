import 'dart:io';

import '../../../core/utils/result.dart';
import 'analyze_image.dart';
import 'generate_title.dart';
import 'image_analysis.dart';
import 'title_result.dart';

class RunTitlePipelineUseCase {
  final AnalyzeImageUseCase _analyzeImage;
  final GenerateTitleUseCase _generateTitle;

  RunTitlePipelineUseCase(this._analyzeImage, this._generateTitle);

  Future<Result<TitleResult>> call({
    required File image,
    required String styleId,
  }) async {
    final analysis = await _analyzeImage(image);
    if (analysis is Failure<ImageAnalysis>) {
      return Failure(analysis.failure);
    }

    final tags = (analysis as Success<ImageAnalysis>).data.tags;
    return _generateTitle(tags: tags, styleId: styleId);
  }
}
