import 'dart:io';
import '../../../core/utils/result.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';

// @LazySingleton(as: TitleRepository, env: ['dev'])
class MockTitleRepository implements TitleRepository {
  @override
  Future<Result<ImageAnalysis>> analyzeImage(
    File image, {
    bool useCache = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Success(ImageAnalysis(tags: ['mock', 'test', 'funny']));
  }

  @override
  Future<Result<TitleResult>> generateTitle({
    required List<String> tags,
    required String styleId,
    List<String> recentTitles = const [],
    String? llmModel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Success(TitleResult(
      text: '[$styleId] Mock 생성된 자막입니다!',
      presetType: styleId,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<Result<TitleResult>> generateTitleFromImage({
    required File image,
    required String styleId,
    bool useCache = true,
    String? llmModel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return Success(TitleResult(
      text: '[$styleId] One-shot Mock 자막입니다!',
      presetType: styleId,
      timestamp: DateTime.now(),
    ));
  }
}
