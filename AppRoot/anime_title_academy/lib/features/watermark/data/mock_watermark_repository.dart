import 'dart:io';
import '../../../core/utils/result.dart';
import '../../title_academy/domain/title_result.dart';
import '../domain/title_style.dart';
import '../domain/watermark_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WatermarkRepository, env: ['dev'])
class MockWatermarkRepository implements WatermarkRepository {
  @override
  Future<Result<File>> compositeTitleAndWatermark({
    required File sourceImage,
    required TitleResult titleResult,
    required TitleStyle titleStyle,
    required bool showWatermark,
  }) async {
    // 실제 렌더링 대신 지연 시간만 시뮬레이션하고 원본 파일 그대로 반환
    await Future.delayed(const Duration(milliseconds: 700));
    return Success(sourceImage);
  }
}
