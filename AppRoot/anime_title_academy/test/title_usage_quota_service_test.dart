import 'package:anime_title_academy/core/config/app_runtime_config.dart';
import 'package:anime_title_academy/features/title_academy/data/title_usage_local_datasource.dart';
import 'package:anime_title_academy/features/title_academy/domain/quota_consume_result.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_usage_quota_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TitleUsageQuotaService', () {
    test('consumes daily free quota before rewarded quota', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final service = TitleUsageQuotaService(
        TitleUsageLocalDatasource(preferences),
        AppRuntimeConfig.resolve(
          isDebugBuild: false,
          forceQuotaAndAds: false,
          rewardedAdModeOverride: 'production',
        ),
        nowProvider: () => DateTime(2026, 3, 24, 9),
      );

      for (var index = 0; index < 5; index++) {
        final result = await service.consume(TitleGenerationModel.fast);
        expect(result.status, QuotaConsumeStatus.consumedFree);
      }

      await service.reward(TitleGenerationModel.fast);

      final rewardedConsume = await service.consume(TitleGenerationModel.fast);
      final quota = rewardedConsume.quota.forModel(TitleGenerationModel.fast);

      expect(rewardedConsume.status, QuotaConsumeStatus.consumedRewarded);
      expect(quota.dailyFreeRemaining, 0);
      expect(quota.rewardedRemaining, 2);
    });

    test('resets free and rewarded quota when the date changes', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final datasource = TitleUsageLocalDatasource(preferences);
      final service = TitleUsageQuotaService(
        datasource,
        AppRuntimeConfig.resolve(
          isDebugBuild: false,
          forceQuotaAndAds: false,
          rewardedAdModeOverride: 'production',
        ),
        nowProvider: () => DateTime(2026, 3, 24, 9),
      );

      await service.consume(TitleGenerationModel.highQuality);
      await service.reward(TitleGenerationModel.highQuality);

      final nextDayService = TitleUsageQuotaService(
        datasource,
        AppRuntimeConfig.resolve(
          isDebugBuild: false,
          forceQuotaAndAds: false,
          rewardedAdModeOverride: 'production',
        ),
        nowProvider: () => DateTime(2026, 3, 25, 0, 1),
      );

      final quota = await nextDayService.getQuota();
      final highQualityQuota = quota.forModel(TitleGenerationModel.highQuality);

      expect(highQualityQuota.dailyFreeRemaining, 1);
      expect(highQualityQuota.rewardedRemaining, 0);
      expect(quota.lastResetDateKey, '2026-03-25');
    });

    test('bypasses limits in normal debug mode', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final service = TitleUsageQuotaService(
        TitleUsageLocalDatasource(preferences),
        AppRuntimeConfig.resolve(
          isDebugBuild: true,
          forceQuotaAndAds: false,
          rewardedAdModeOverride: 'auto',
        ),
        nowProvider: () => DateTime(2026, 3, 24, 9),
      );

      for (var index = 0; index < 3; index++) {
        final result = await service.consume(TitleGenerationModel.highQuality);
        expect(result.status, QuotaConsumeStatus.bypassed);
        expect(result.quota.isBypassed, isTrue);
      }
    });
  });
}
