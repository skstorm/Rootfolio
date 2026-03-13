import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/share_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ShareService)
class ShareServiceImpl implements ShareService {
  @override
  Future<Result<bool>> saveToGallery(File image) async {
    try {
      // TODO: 실제로 image_gallery_saver 등 패키지 사용하여 갤러리 저장
      await Future.delayed(const Duration(milliseconds: 500));
      return const Success(true);
    } catch (e) {
      return const Failure(StorageFailure('이미지 저장에 실패했습니다. 권한을 확인해주세요.'));
    }
  }

  @override
  Future<Result<bool>> shareToOtherApps(File image, {String text = ''}) async {
    try {
      // TODO: share_plus 패키지로 타 앱 공유
      await Future.delayed(const Duration(milliseconds: 500));
      return const Success(true);
    } catch (e) {
      return const Failure(ServerFailure('공유 중 오류가 발생했습니다.'));
    }
  }
}
