import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/config/app_runtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRuntimeConfig', () {
    test('bypasses quota and disables ads on normal debug auto mode', () {
      final config = AppRuntimeConfig.resolve(
        isDebugBuild: true,
        forceQuotaAndAds: false,
        rewardedAdModeOverride: 'auto',
      );

      expect(config.bypassQuotaAndAds, isTrue);
      expect(config.rewardedAdMode, RewardedAdMode.disabled);
    });

    test('enforces quota and uses test ads when forced in debug', () {
      final config = AppRuntimeConfig.resolve(
        isDebugBuild: true,
        forceQuotaAndAds: true,
        rewardedAdModeOverride: 'auto',
      );

      expect(config.bypassQuotaAndAds, isFalse);
      expect(config.rewardedAdMode, RewardedAdMode.test);
    });

    test('uses production ads on release auto mode', () {
      final config = AppRuntimeConfig.resolve(
        isDebugBuild: false,
        forceQuotaAndAds: false,
        rewardedAdModeOverride: 'auto',
      );

      expect(config.bypassQuotaAndAds, isFalse);
      expect(config.rewardedAdMode, RewardedAdMode.production);
    });

    test('honors fake ad mode override', () {
      final config = AppRuntimeConfig.resolve(
        isDebugBuild: true,
        forceQuotaAndAds: true,
        rewardedAdModeOverride: 'fake',
      );

      expect(config.bypassQuotaAndAds, isFalse);
      expect(config.rewardedAdMode, RewardedAdMode.fake);
    });
  });
}
