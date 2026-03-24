import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:flutter/foundation.dart';

class AppRuntimeConfig {
  const AppRuntimeConfig({
    required this.isDebugBuild,
    required this.forceQuotaAndAds,
    required this.rewardedAdMode,
  });

  static const bool _forceQuotaAndAdsFromEnv = bool.fromEnvironment(
    'FORCE_QUOTA_AND_ADS',
    defaultValue: false,
  );
  static const String _rewardedAdModeFromEnv = String.fromEnvironment(
    'REWARDED_AD_MODE',
    defaultValue: 'auto',
  );

  final bool isDebugBuild;
  final bool forceQuotaAndAds;
  final RewardedAdMode rewardedAdMode;

  factory AppRuntimeConfig.fromEnvironment() {
    return AppRuntimeConfig.resolve(
      isDebugBuild: kDebugMode,
      forceQuotaAndAds: _forceQuotaAndAdsFromEnv,
      rewardedAdModeOverride: _rewardedAdModeFromEnv,
    );
  }

  factory AppRuntimeConfig.resolve({
    required bool isDebugBuild,
    required bool forceQuotaAndAds,
    required String rewardedAdModeOverride,
  }) {
    final bypassQuotaAndAds = isDebugBuild && !forceQuotaAndAds;
    final rewardedAdMode = RewardedAdModeX.resolve(
      rewardedAdModeOverride,
      isDebugBuild: isDebugBuild,
      bypassQuotaAndAds: bypassQuotaAndAds,
    );
    return AppRuntimeConfig(
      isDebugBuild: isDebugBuild,
      forceQuotaAndAds: forceQuotaAndAds,
      rewardedAdMode: rewardedAdMode,
    );
  }

  bool get bypassQuotaAndAds => isDebugBuild && !forceQuotaAndAds;
}
