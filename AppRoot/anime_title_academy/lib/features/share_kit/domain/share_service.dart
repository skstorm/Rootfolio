import 'dart:io';
import '../../../core/utils/result.dart';

abstract class ShareService {
  Future<Result<File>> saveToGallery(File image);
  Future<Result<bool>> shareToOtherApps(File image, {String text = ''});
}
