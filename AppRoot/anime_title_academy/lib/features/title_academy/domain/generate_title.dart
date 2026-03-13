import '../../../core/utils/result.dart';
import 'title_result.dart';
import 'title_repository.dart';

class GenerateTitleUseCase {
  final TitleRepository _repository;

  GenerateTitleUseCase(this._repository);

  Future<Result<TitleResult>> call({
    required List<String> tags,
    required String presetType,
    required String presetPrompt,
  }) async {
    return await _repository.generateTitle(
      tags: tags,
      presetType: presetType,
      presetPrompt: presetPrompt,
    );
  }
}
