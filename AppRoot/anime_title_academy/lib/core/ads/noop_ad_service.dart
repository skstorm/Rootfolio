import 'package:anime_title_academy/core/ads/ad_reward_result.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

class NoopAdService implements AdService {
  const NoopAdService();

  @override
  RewardedAdMode get mode => RewardedAdMode.disabled;

  @override
  Future<AdRewardResult> showRewardedAd({
    required TitleGenerationModel model,
  }) async {
    return const AdRewardResult(
      status: AdRewardStatus.unavailable,
      message: '현재 빌드에서는 광고가 비활성화되어 있습니다.',
    );
  }
}
