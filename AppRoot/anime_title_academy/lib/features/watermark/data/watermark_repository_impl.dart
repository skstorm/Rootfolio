import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';
import '../../title_academy/domain/title_result.dart';
import '../domain/title_style.dart';
import '../domain/watermark_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WatermarkRepository, env: ['prod', 'staging'])
class WatermarkRepositoryImpl implements WatermarkRepository {
  @override
  Future<Result<File>> compositeTitleAndWatermark({
    required File sourceImage,
    required TitleResult titleResult,
    required TitleStyle titleStyle,
    required bool showWatermark,
  }) async {
    try {
      // TODO: 실제 image 패키지를 사용하여 이미지 스트림 렌더링, 옐로우/블랙 텍스트 그리기 및 워터마크 병합 로직
      await Future.delayed(const Duration(seconds: 1));
      return Success(sourceImage); // 임시로 원본 파일 반환
    } catch (e) {
      return const Failure(ServerFailure('텍스트 합성 중 오류가 발생했습니다.'));
    }
  }
}
