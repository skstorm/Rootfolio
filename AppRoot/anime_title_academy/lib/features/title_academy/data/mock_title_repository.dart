import 'dart:io';
import '../../../core/utils/result.dart';
import '../domain/image_analysis.dart';
import '../domain/title_repository.dart';
import '../domain/title_result.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TitleRepository, env: ['dev'])
class MockTitleRepository implements TitleRepository {
  @override
  Future<Result<ImageAnalysis>> analyzeVariables(File image) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Success(ImageAnalysis(tags: ['mock', 'test', 'funny']));
  }

  @override
  Future<Result<TitleResult>> generateTitle({
    required List<String> tags,
    required String presetType,
    required String presetPrompt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Success(TitleResult(
      text: '[$presetType] Mock 생성된 자막입니다!',
      presetType: presetType,
      timestamp: DateTime.now(),
    ));
  }
}
