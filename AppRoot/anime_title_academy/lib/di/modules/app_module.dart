import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ads/ad_runtime_mode.dart';
import '../../core/ads/ad_service.dart';
import '../../core/ads/fake_rewarded_ad_service.dart';
import '../../core/ads/google_rewarded_ad_service.dart';
import '../../core/ads/noop_ad_service.dart';
import '../../core/config/app_runtime_config.dart';


@module
abstract class AppModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  AppRuntimeConfig get runtimeConfig => AppRuntimeConfig.fromEnvironment();

  @lazySingleton
  AdService getAdService(AppRuntimeConfig runtimeConfig) {
    switch (runtimeConfig.rewardedAdMode) {
      case RewardedAdMode.disabled:
        return const NoopAdService();
      case RewardedAdMode.fake:
        return const FakeRewardedAdService();
      case RewardedAdMode.test:
        return const GoogleRewardedAdService(mode: RewardedAdMode.test);
      case RewardedAdMode.production:
        return const GoogleRewardedAdService(mode: RewardedAdMode.production);
    }
  }
}
