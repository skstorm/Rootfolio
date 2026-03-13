import 'dart:io';
import '../../../core/utils/result.dart';
import '../../title_academy/domain/title_result.dart';
import 'title_style.dart';
import 'watermark_repository.dart';

class CompositeTitleUseCase {
  final WatermarkRepository _repository;

  CompositeTitleUseCase(this._repository);

  Future<Result<File>> call({
    required File image,
    required TitleResult titleResult,
    required TitleStyle titleStyle,
  }) async {
    return await _repository.compositeTitleAndWatermark(
      sourceImage: image,
      titleResult: titleResult,
      titleStyle: titleStyle,
      showWatermark: true, // 기본값 강제 (추후 Billing 연동)
    );
  }
}
