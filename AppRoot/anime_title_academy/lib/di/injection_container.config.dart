// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../core/config/app_config.dart' as _i221;
import '../core/logging/app_logger.dart' as _i412;
import '../core/network/ai_client.dart' as _i303;
import '../core/network/api_client.dart' as _i510;
import '../core/network/gemini_api_key_client.dart' as _i259;
import '../features/analytics/data/mock_analytics_tracker.dart' as _i982;
import '../features/analytics/domain/analytics_tracker.dart' as _i103;
import '../features/gallery/data/gallery_repository_impl.dart' as _i1039;
import '../features/gallery/domain/gallery_repository.dart' as _i338;
import '../features/image_gen/data/image_gen_repository_impl.dart' as _i406;
import '../features/image_gen/data/mock_image_gen_repository.dart' as _i945;
import '../features/image_gen/domain/image_gen_repository.dart' as _i533;
import '../features/share_kit/data/share_service_impl.dart' as _i798;
import '../features/share_kit/domain/share_service.dart' as _i429;
import '../features/title_academy/data/gemini_llm_datasource.dart' as _i959;
import '../features/title_academy/data/gemini_vision_datasource.dart' as _i116;
import '../features/title_academy/data/image_analysis_cache.dart' as _i368;
import '../features/title_academy/data/image_payload_preparer.dart' as _i552;
import '../features/title_academy/data/prompt_template_service.dart' as _i561;
import '../features/title_academy/data/title_repository_impl.dart' as _i900;
import '../features/title_academy/domain/title_repository.dart' as _i290;
import '../features/watermark/data/mock_watermark_repository.dart' as _i413;
import '../features/watermark/data/watermark_repository_impl.dart' as _i715;
import '../features/watermark/domain/watermark_repository.dart' as _i553;

const String _dev = 'dev';
const String _prod = 'prod';
const String _staging = 'staging';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i552.ImagePayloadPreparer>(() => _i552.ImagePayloadPreparer());
    gh.lazySingleton<_i221.AppConfig>(() => _i221.AppConfig());
    gh.lazySingleton<_i412.AppLogger>(() => _i412.AppLogger());
    gh.lazySingleton<_i510.ApiClient>(() => _i510.ApiClient());
    gh.lazySingleton<_i368.ImageAnalysisCache>(
      () => _i368.ImageAnalysisCache(),
    );
    gh.lazySingleton<_i561.PromptTemplateService>(
      () => _i561.PromptTemplateService(),
    );
    gh.lazySingleton<_i533.ImageGenRepository>(
      () => _i945.MockImageGenRepository(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i338.GalleryRepository>(
      () => _i1039.GalleryRepositoryImpl(),
    );
    gh.lazySingleton<_i303.AiClient>(
      () => _i259.GeminiApiKeyClient(
        gh<_i221.AppConfig>(),
        gh<_i412.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i553.WatermarkRepository>(
      () => _i413.MockWatermarkRepository(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i429.ShareService>(() => _i798.ShareServiceImpl());
    gh.lazySingleton<_i103.AnalyticsTracker>(
      () => _i982.MockAnalyticsTracker(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i553.WatermarkRepository>(
      () => _i715.WatermarkRepositoryImpl(),
      registerFor: {_prod, _staging},
    );
    gh.factory<_i959.GeminiLlmDatasource>(
      () => _i959.GeminiLlmDatasource(gh<_i303.AiClient>()),
    );
    gh.lazySingleton<_i533.ImageGenRepository>(
      () => _i406.ImageGenRepositoryImpl(gh<_i510.ApiClient>()),
      registerFor: {_prod, _staging},
    );
    gh.factory<_i116.GeminiVisionDatasource>(
      () => _i116.GeminiVisionDatasource(
        gh<_i303.AiClient>(),
        gh<_i552.ImagePayloadPreparer>(),
        gh<_i368.ImageAnalysisCache>(),
        gh<_i412.AppLogger>(),
      ),
    );
    gh.lazySingleton<_i290.TitleRepository>(
      () => _i900.TitleRepositoryImpl(
        gh<_i116.GeminiVisionDatasource>(),
        gh<_i959.GeminiLlmDatasource>(),
        gh<_i561.PromptTemplateService>(),
        gh<_i412.AppLogger>(),
      ),
    );
    return this;
  }
}
