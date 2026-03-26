import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

import '../../../core/constants/ai_pipeline_constants.dart';

@injectable
class ImagePayloadPreparer {
  Future<Uint8List> prepare(File source) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return Uint8List.fromList(bytes);
    }

    final resized = _resizeIfNeeded(decoded);
    final encoded = Uint8List.fromList(
      img.encodeJpg(resized, quality: AiPipelineConstants.visionJpegQuality),
    );

    if (encoded.length >= bytes.length) {
      return Uint8List.fromList(bytes);
    }

    return encoded;
  }

  Future<String> buildCacheKey(File source) async {
    final stat = await source.stat();
    return [
      source.path,
      stat.size,
      stat.modified.millisecondsSinceEpoch,
      AiPipelineConstants.visionMaxImageDimension,
      AiPipelineConstants.visionJpegQuality,
    ].join('|');
  }

  img.Image _resizeIfNeeded(img.Image image) {
    final width = image.width;
    final height = image.height;
    if (width <= AiPipelineConstants.visionMaxImageDimension &&
        height <= AiPipelineConstants.visionMaxImageDimension) {
      return image;
    }

    if (width >= height) {
      final resizedHeight =
          (height * (AiPipelineConstants.visionMaxImageDimension / width)).round();
      return img.copyResize(
        image,
        width: AiPipelineConstants.visionMaxImageDimension,
        height: resizedHeight,
      );
    }

    final resizedWidth =
        (width * (AiPipelineConstants.visionMaxImageDimension / height)).round();
    return img.copyResize(
      image,
      width: resizedWidth,
      height: AiPipelineConstants.visionMaxImageDimension,
    );
  }
}
