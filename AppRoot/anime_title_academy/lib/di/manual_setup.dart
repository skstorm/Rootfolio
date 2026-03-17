import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../core/network/ai_client.dart';
import '../core/network/gemini_api_key_client.dart';
import '../features/title_academy/data/gemini_vision_datasource.dart';
import '../features/title_academy/data/gemini_llm_datasource.dart';
import '../features/title_academy/data/title_repository_impl.dart';
import '../features/title_academy/data/prompt_template_service.dart';
import '../features/title_academy/domain/title_repository.dart';
import '../features/gallery/data/gallery_repository_impl.dart';
import '../features/gallery/domain/gallery_repository.dart';
import '../features/share_kit/data/share_service_impl.dart';
import '../features/share_kit/domain/share_service.dart';
import '../features/image_gen/data/image_gen_repository_impl.dart';
import '../features/image_gen/domain/image_gen_repository.dart';
import '../features/watermark/data/watermark_repository_impl.dart';
import '../features/watermark/domain/watermark_repository.dart';
import '../features/analytics/data/mock_analytics_tracker.dart';
import '../features/analytics/domain/analytics_tracker.dart';

/// build_runner 크래시 오류 해결을 위한 수동 DI 설정 (임시/상용 병행 가능)
void manualSetup(GetIt getIt, String env) {
  // 1. Core Network
  final apiClient = ApiClient();
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() => apiClient);
  }
  
  if (!getIt.isRegistered<AiClient>()) {
    getIt.registerLazySingleton<AiClient>(() => GeminiApiKeyClient());
  }

  // 2. DataSources
  if (!getIt.isRegistered<GeminiVisionDatasource>()) {
    getIt.registerFactory(() => GeminiVisionDatasource(getIt<AiClient>()));
  }
  if (!getIt.isRegistered<GeminiLlmDatasource>()) {
    getIt.registerFactory(() => GeminiLlmDatasource(getIt<AiClient>()));
  }

  if (!getIt.isRegistered<PromptTemplateService>()) {
    getIt.registerLazySingleton<PromptTemplateService>(() => PromptTemplateService());
  }

  if (!getIt.isRegistered<TitleRepository>()) {
    getIt.registerLazySingleton<TitleRepository>(() => TitleRepositoryImpl(
      getIt<GeminiVisionDatasource>(),
      getIt<GeminiLlmDatasource>(),
      getIt<PromptTemplateService>(),
    ));
  }
  
  if (!getIt.isRegistered<GalleryRepository>()) {
    getIt.registerLazySingleton<GalleryRepository>(() => GalleryRepositoryImpl());
  }
  
  if (!getIt.isRegistered<ShareService>()) {
    getIt.registerLazySingleton<ShareService>(() => ShareServiceImpl());
  }
  
  if (!getIt.isRegistered<ImageGenRepository>()) {
    getIt.registerLazySingleton<ImageGenRepository>(() => ImageGenRepositoryImpl(getIt<ApiClient>()));
  }
  
  if (!getIt.isRegistered<WatermarkRepository>()) {
    getIt.registerLazySingleton<WatermarkRepository>(() => WatermarkRepositoryImpl());
  }
  
  if (!getIt.isRegistered<AnalyticsTracker>()) {
    getIt.registerLazySingleton<AnalyticsTracker>(() => MockAnalyticsTracker());
  }
}
