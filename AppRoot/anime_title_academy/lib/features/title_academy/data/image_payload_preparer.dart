import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

@injectable
class ImagePayloadPreparer {
  static const int _maxDimension = 1280;
  static const int _jpegQuality = 85;

  Future<File> prepare(File source) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return source;
    }

    final resized = _resizeIfNeeded(decoded);
    final encoded = Uint8List.fromList(
      img.encodeJpg(resized, quality: _jpegQuality),
    );

    if (encoded.length >= bytes.length) {
      return source;
    }

    final tempFile = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}anime_title_academy_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(encoded, flush: true);
    return tempFile;
  }

  img.Image _resizeIfNeeded(img.Image image) {
    final width = image.width;
    final height = image.height;
    if (width <= _maxDimension && height <= _maxDimension) {
      return image;
    }

    if (width >= height) {
      final resizedHeight = (height * (_maxDimension / width)).round();
      return img.copyResize(image, width: _maxDimension, height: resizedHeight);
    }

    final resizedWidth = (width * (_maxDimension / height)).round();
    return img.copyResize(image, width: resizedWidth, height: _maxDimension);
  }
}
