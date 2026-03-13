import 'dart:io';
import '../../../core/utils/result.dart';

abstract class ShareService {
  Future<Result<bool>> saveToGallery(File image);
  Future<Result<bool>> shareToOtherApps(File image, {String text = ''});
}
