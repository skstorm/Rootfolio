import 'dart:io';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/result.dart';
import '../domain/image_gen_repository.dart';
import '../domain/transformed_image.dart';
import 'stable_diffusion_datasource.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ImageGenRepository, env: ['prod', 'staging'])
class ImageGenRepositoryImpl implements ImageGenRepository {
  final StableDiffusionDatasource _datasource;

  ImageGenRepositoryImpl(ApiClient apiClient)
      : _datasource = StableDiffusionDatasource(apiClient.dio);

  @override
  List<String> get availableStyles => ['youth', 'isekai', 'battle'];

  @override
  Future<Result<TransformedImage>> transformImage({
    required File source,
    required String stylePrompt,
  }) async {
    try {
      // 장르별 특화 SD 프롬프트 매핑
      String sdPrompt;
      if (stylePrompt == 'youth') {
        sdPrompt = "Shinkai Makoto style, anime background, lens flare, bright sunshine, highly detailed, masterpieces, 4k";
      } else if (stylePrompt == 'isekai') {
        sdPrompt = "High fantasy world, RPG game style, magic particles everywhere, medieval castle interior, vibrant colors, anime art style";
      } else if (stylePrompt == 'battle') {
        sdPrompt = "90s retro anime style, cel shaded, high contrast, action lines, dramatic lighting, grit, intense expression";
      } else {
        sdPrompt = "Anime art style, high quality";
      }

      final sdResponse = await _datasource.transformImage(source, sdPrompt);

      if (sdResponse.base64Image.isEmpty) {
        // SD API가 빈 이미지를 반환하면 원본으로 폴백
        return Success(TransformedImage(file: source, style: stylePrompt, isOriginal: true));
      }

      // NSFW 필터 (간이: 경고 메시지 내 키워드 체크)
      if (sdResponse.warning != null && sdResponse.warning!.toLowerCase().contains('nsfw')) {
        return const Failure(ServerFailure('부적절한 이미지로 변환이 거부되었습니다.'));
      }

      final resultFile = await _datasource.base64ToFile(sdResponse.base64Image);
      return Success(TransformedImage(file: resultFile, style: stylePrompt));
    } on Exception catch (e) {
      // API 실패 시 원본 이미지로 폴백
      return Success(TransformedImage(file: source, style: stylePrompt, isOriginal: true));
    }
  }
}
