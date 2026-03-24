import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/config/app_runtime_config.dart';
import 'package:anime_title_academy/core/constants/ad_unit_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MobileAdsBootstrap {
  const MobileAdsBootstrap._();

  static Future<void> initializeIfNeeded(AppRuntimeConfig runtimeConfig) async {
    if (runtimeConfig.rewardedAdMode == RewardedAdMode.disabled ||
        runtimeConfig.rewardedAdMode == RewardedAdMode.fake) {
      return;
    }
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    if (runtimeConfig.rewardedAdMode == RewardedAdMode.production &&
        AdUnitConstants.resolveRewardedAdUnitId(
              RewardedAdMode.production,
            ) ==
            null) {
      throw StateError(
        'Missing rewarded ad unit id for production mode. '
        'Pass ADMOB_ANDROID_REWARDED_AD_UNIT_ID or ADMOB_IOS_REWARDED_AD_UNIT_ID.',
      );
    }

    await MobileAds.instance.initialize();
  }
}
