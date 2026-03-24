import 'package:anime_title_academy/core/ads/ad_reward_result.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

abstract class AdService {
  RewardedAdMode get mode;

  Future<AdRewardResult> showRewardedAd({
    required TitleGenerationModel model,
  });
}
