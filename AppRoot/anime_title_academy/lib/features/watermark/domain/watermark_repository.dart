import 'dart:io';
import '../../../core/utils/result.dart';
import '../../title_academy/domain/title_result.dart';
import 'title_style.dart';

abstract class WatermarkRepository {
  /// 원본 이미지 위에 자막 텍스트와 워터마크를 합성하여 새로운 이미지 파일로 반환
  Future<Result<File>> compositeTitleAndWatermark({
    required File sourceImage,
    required TitleResult titleResult,
    required TitleStyle titleStyle,
    required bool showWatermark,
  });
}
