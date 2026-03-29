import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
      final originalBytes = await sourceImage.readAsBytes();
      final codec = await ui.instantiateImageCodec(originalBytes);
      final frame = await codec.getNextFrame();
      final source = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()),
      );

      canvas.drawImage(source, Offset.zero, Paint());

      final imageWidth = source.width.toDouble();
      final imageHeight = source.height.toDouble();
      final panelHorizontalMargin = imageWidth * 0.06;
      final panelWidth = imageWidth - (panelHorizontalMargin * 2);
      final panelHeight = (imageHeight * 0.17).clamp(88.0, 190.0);
      final panelBottom = imageHeight * 0.07;
      final panelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          panelHorizontalMargin,
          imageHeight - panelBottom - panelHeight,
          panelWidth,
          panelHeight,
        ),
        Radius.circular(panelHeight * 0.18),
      );

      canvas.drawRRect(
        panelRect,
        Paint()..color = Colors.black.withValues(alpha: 0.42),
      );

      final maxTextWidth = panelWidth - 28;
      final fillFontSize =
          (titleStyle.fontSize * (imageWidth / 390.0)).clamp(20.0, 42.0);
      final strokeWidth = (titleStyle.strokeWidth * (imageWidth / 390.0))
          .clamp(2.0, 5.0);
      final strokePaintStyle = TextStyle(
        color: titleStyle.strokeColor,
        fontSize: fillFontSize,
        fontWeight: FontWeight.w900,
        height: 1.1,
      );
      final fillPaintStyle = TextStyle(
        color: titleStyle.fillColor,
        fontSize: fillFontSize,
        fontWeight: FontWeight.w900,
        height: 1.1,
      );

      final fillPainter = TextPainter(
        text: TextSpan(text: titleResult.text, style: fillPaintStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '...',
      )..layout(maxWidth: maxTextWidth);

      final textOffset = Offset(
        panelRect.left + ((panelWidth - fillPainter.width) / 2),
        panelRect.top + ((panelHeight - fillPainter.height) / 2),
      );

      final outlineOffsets = <Offset>[
        Offset(-strokeWidth, -strokeWidth),
        Offset(0, -strokeWidth),
        Offset(strokeWidth, -strokeWidth),
        Offset(-strokeWidth, 0),
        Offset(strokeWidth, 0),
        Offset(-strokeWidth, strokeWidth),
        Offset(0, strokeWidth),
        Offset(strokeWidth, strokeWidth),
      ];

      for (final offset in outlineOffsets) {
        final strokePainter = TextPainter(
          text: TextSpan(text: titleResult.text, style: strokePaintStyle),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 2,
          ellipsis: '...',
        )..layout(maxWidth: maxTextWidth);
        strokePainter.paint(canvas, textOffset + offset);
      }
      fillPainter.paint(canvas, textOffset);

      if (showWatermark) {
        final watermarkPainter = TextPainter(
          text: const TextSpan(
            text: 'Anime Title Academy',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: imageWidth * 0.5);

        watermarkPainter.paint(
          canvas,
          Offset(
            imageWidth - watermarkPainter.width - 16,
            imageHeight - watermarkPainter.height - 16,
          ),
        );
      }

      final picture = recorder.endRecording();
      final rendered = await picture.toImage(source.width, source.height);
      final byteData = await rendered.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return const Failure(StorageFailure('합성 이미지를 생성하지 못했습니다.'));
      }

      final savedFile = await _writeTempFile(
        byteData.buffer.asUint8List(),
        sourceImage.path,
      );
      return Success(savedFile);
    } catch (e) {
      return const Failure(ServerFailure('텍스트 합성 중 오류가 발생했습니다.'));
    }
  }

  Future<File> _writeTempFile(Uint8List bytes, String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final extension = _extensionOf(sourcePath).toLowerCase() == '.png'
        ? '.png'
        : '.png';
    final file = File(
      _joinPath(
        tempDir.path,
        'anime_title_result_${DateTime.now().millisecondsSinceEpoch}$extension',
      ),
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
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
