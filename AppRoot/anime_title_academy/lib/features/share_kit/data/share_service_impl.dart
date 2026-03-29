import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/share_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ShareService)
class ShareServiceImpl implements ShareService {
  @override
  Future<Result<File>> saveToGallery(File image) async {
    try {
      final targetDirectory = await _resolveSaveDirectory();
      await targetDirectory.create(recursive: true);

      final extension = _extensionOf(image.path);
      final fileName =
          'anime_title_academy_${DateTime.now().millisecondsSinceEpoch}$extension';
      final savedFile = await image.copy(_joinPath(targetDirectory.path, fileName));
      return Success(savedFile);
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

  Future<Directory> _resolveSaveDirectory() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        return Directory(_joinPath(downloads.path, 'AnimeTitleAcademy'));
      }
      final documents = await getApplicationDocumentsDirectory();
      return Directory(_joinPath(documents.path, 'AnimeTitleAcademy'));
    }

    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return Directory(_joinPath(externalDir.path, 'AnimeTitleAcademy'));
      }
    }

    final documents = await getApplicationDocumentsDirectory();
    return Directory(_joinPath(documents.path, 'AnimeTitleAcademy'));
  }

  String _joinPath(String base, String child) {
    return '$base${Platform.pathSeparator}$child';
  }

  String _extensionOf(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex < filePath.lastIndexOf(Platform.pathSeparator)) {
      return '.png';
    }
    return filePath.substring(dotIndex);
  }
}
