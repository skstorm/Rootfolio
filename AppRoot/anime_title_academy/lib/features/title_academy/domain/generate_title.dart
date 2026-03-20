import '../../../core/utils/result.dart';
import 'title_result.dart';
import 'title_repository.dart';

class GenerateTitleUseCase {
  final TitleRepository _repository;

  GenerateTitleUseCase(this._repository);

  Future<Result<TitleResult>> call({
    required List<String> tags,
    required String styleId,
    List<String> recentTitles = const [],
  }) async {
    return await _repository.generateTitle(
      tags: tags,
      styleId: styleId,
      recentTitles: recentTitles,
    );
  }
}
