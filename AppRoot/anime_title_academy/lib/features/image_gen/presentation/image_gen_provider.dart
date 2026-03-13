import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/injection_container.dart';
import '../domain/image_gen_repository.dart';
import '../domain/transform_image.dart';
import '../domain/transformed_image.dart';
import '../../../core/utils/result.dart';

// 상태 정의
abstract class ImageGenState {}
class ImageGenInitial extends ImageGenState {}
class ImageGenLoading extends ImageGenState {}
class ImageGenSuccess extends ImageGenState {
  final TransformedImage result;
  ImageGenSuccess(this.result);
}
class ImageGenError extends ImageGenState {
  final String message;
  ImageGenError(this.message);
}

final imageGenProvider = NotifierProvider<ImageGenNotifier, ImageGenState>(() {
  return ImageGenNotifier();
});

class ImageGenNotifier extends Notifier<ImageGenState> {
  late final TransformImageUseCase _useCase;

  @override
  ImageGenState build() {
    final repo = getIt<ImageGenRepository>();
    _useCase = TransformImageUseCase(repo);
    return ImageGenInitial();
  }

  Future<TransformedImage?> transform(File image, String style) async {
    state = ImageGenLoading();
    final result = await _useCase(source: image, stylePrompt: style);

    if (result is Success<TransformedImage>) {
      final data = result.data;
      state = ImageGenSuccess(data);
      return data;
    } else {
      final f = result as Failure;
      state = ImageGenError(f.failure.message);
      // 실패 시 원본으로 폴백 처리 (사용자에게는 변환 실패를 알리되 앱은 계속 진행)
      return TransformedImage(file: image, style: style, isOriginal: true);
    }
  }

  void reset() {
    state = ImageGenInitial();
  }
}
