import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/core/ads/fake_rewarded_ad_service.dart';
import 'package:anime_title_academy/core/ads/google_rewarded_ad_service.dart';
import 'package:anime_title_academy/core/ads/noop_ad_service.dart';
import 'package:anime_title_academy/core/config/app_runtime_config.dart';
import 'package:anime_title_academy/features/title_academy/data/title_usage_local_datasource.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_usage_quota_service.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(String env) async {
  getIt.init(environment: env);

  if (!getIt.isRegistered<AppRuntimeConfig>()) {
    getIt.registerSingleton<AppRuntimeConfig>(AppRuntimeConfig.fromEnvironment());
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    final preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(preferences);
  }

  if (!getIt.isRegistered<TitleUsageLocalDatasource>()) {
    getIt.registerLazySingleton<TitleUsageLocalDatasource>(
      () => TitleUsageLocalDatasource(getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<TitleUsageQuotaService>()) {
    getIt.registerLazySingleton<TitleUsageQuotaService>(
      () => TitleUsageQuotaService(
        getIt<TitleUsageLocalDatasource>(),
        getIt<AppRuntimeConfig>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdService>()) {
    getIt.registerLazySingleton<AdService>(() {
      final runtimeConfig = getIt<AppRuntimeConfig>();
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
    });
  }
}
