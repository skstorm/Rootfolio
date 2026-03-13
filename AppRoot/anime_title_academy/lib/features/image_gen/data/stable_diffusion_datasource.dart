import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'sd_response_model.dart';

class StableDiffusionDatasource {
  final Dio _dio;
  static const String _baseUrl = 'https://api.your-sd-server.com'; // TODO: 실제 SD API URL 기입
  static const int _maxPixels = 2048;
  static const int _timeoutSec = 30;

  StableDiffusionDatasource(this._dio);

  Future<SdResponseModel> transformImage(File source, String stylePrompt) async {
    // 1. 이미지 리사이즈 (최대 _maxPixels)
    final resizedBytes = await _resizeImage(source);

    // 2. Base64 인코딩
    final base64Input = base64Encode(resizedBytes);

    // 3. SD img2img API 호출
    final response = await _dio.post(
      '$_baseUrl/sdapi/v1/img2img',
      data: {
        'init_images': [base64Input],
        'prompt': stylePrompt,
        'negative_prompt': 'nsfw, nude, explicit, bad quality',
        'denoising_strength': 0.65,
        'width': 512,
        'height': 512,
        'steps': 20,
      },
      options: Options(
        sendTimeout: const Duration(seconds: _timeoutSec),
        receiveTimeout: const Duration(seconds: _timeoutSec),
      ),
    );

    return SdResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Uint8List> _resizeImage(File source) async {
    final rawBytes = await source.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) return rawBytes;

    if (decoded.width <= _maxPixels && decoded.height <= _maxPixels) {
      return rawBytes;
    }

    final ratio = _maxPixels / (decoded.width > decoded.height ? decoded.width : decoded.height);
    final resized = img.copyResize(
      decoded,
      width: (decoded.width * ratio).round(),
      height: (decoded.height * ratio).round(),
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: 90));
  }

  Future<File> base64ToFile(String base64Str) async {
    final bytes = base64Decode(base64Str);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/sd_result_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }
}
