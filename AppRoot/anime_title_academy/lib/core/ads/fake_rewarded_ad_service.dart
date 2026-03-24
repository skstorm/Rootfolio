import 'dart:async';

import 'package:anime_title_academy/core/ads/ad_reward_result.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

class FakeRewardedAdService implements AdService {
  const FakeRewardedAdService();

  @override
  RewardedAdMode get mode => RewardedAdMode.fake;

  @override
  Future<AdRewardResult> showRewardedAd({
    required TitleGenerationModel model,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return AdRewardResult(
      status: AdRewardStatus.rewarded,
      message: '${model.label} 보상을 가짜 광고 모드로 지급했습니다.',
    );
  }
}
