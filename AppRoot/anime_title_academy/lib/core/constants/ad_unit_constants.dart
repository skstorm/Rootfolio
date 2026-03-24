import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:flutter/foundation.dart';

abstract final class AdUnitConstants {
  static const String androidTestAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const String _androidTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  static const String _androidProductionRewardedAdUnitId =
      String.fromEnvironment(
        'ADMOB_ANDROID_REWARDED_AD_UNIT_ID',
        defaultValue: '',
      );
  static const String _iosProductionRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_AD_UNIT_ID',
    defaultValue: '',
  );

  static String? resolveRewardedAdUnitId(
    RewardedAdMode mode, {
    TargetPlatform? platformOverride,
    bool? isWebOverride,
  }) {
    final isWeb = isWebOverride ?? kIsWeb;
    if (isWeb || mode == RewardedAdMode.disabled) {
      return null;
    }

    final platform = platformOverride ?? defaultTargetPlatform;
    if (platform != TargetPlatform.android &&
        platform != TargetPlatform.iOS) {
      return null;
    }

    switch (mode) {
      case RewardedAdMode.disabled:
      case RewardedAdMode.fake:
        return null;
      case RewardedAdMode.test:
        return platform == TargetPlatform.android
            ? _androidTestRewardedAdUnitId
            : _iosTestRewardedAdUnitId;
      case RewardedAdMode.production:
        final candidate = platform == TargetPlatform.android
            ? _androidProductionRewardedAdUnitId
            : _iosProductionRewardedAdUnitId;
        final normalized = candidate.trim();
        return normalized.isEmpty ? null : normalized;
    }
  }
}
