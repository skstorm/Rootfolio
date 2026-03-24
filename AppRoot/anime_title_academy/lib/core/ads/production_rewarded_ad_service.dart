import 'package:anime_title_academy/core/ads/ad_reward_result.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

class ProductionRewardedAdService implements AdService {
  const ProductionRewardedAdService();

  @override
  RewardedAdMode get mode => RewardedAdMode.production;

  @override
  Future<AdRewardResult> showRewardedAd({
    required TitleGenerationModel model,
  }) async {
    return const AdRewardResult(
      status: AdRewardStatus.unavailable,
      message: '프로덕션 광고 SDK가 아직 연결되지 않았습니다.',
    );
  }
}
