import 'dart:async';

import 'package:anime_title_academy/core/ads/ad_reward_result.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

class TestRewardedAdService implements AdService {
  const TestRewardedAdService();

  @override
  RewardedAdMode get mode => RewardedAdMode.test;

  @override
  Future<AdRewardResult> showRewardedAd({
    required TitleGenerationModel model,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return AdRewardResult(
      status: AdRewardStatus.rewarded,
      message: '${model.label} 보상 지급을 테스트 모드로 처리했습니다.',
    );
  }
}
