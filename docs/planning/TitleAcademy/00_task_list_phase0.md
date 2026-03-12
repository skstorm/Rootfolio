# Task List - Phase 0: 프로젝트 기반 구축

> 모든 Phase의 기초. 이 Phase가 완료되어야 다음 작업 가능.

---

## 0-1. Flutter 프로젝트 생성
- [ ] `flutter create --org com.titlegym anime_title_academy` 실행
- [ ] 최소 Flutter SDK 버전: 3.x 확인
- [ ] Android minSdkVersion: 24, iOS deployment target: 15.0
- **완료 기준**: `flutter run` 으로 기본 앱 실행 확인

## 0-2. 폴더 구조 생성
- [ ] `lib/core/error/` - failures.dart, exceptions.dart
- [ ] `lib/core/network/` - api_client.dart, network_info.dart
- [ ] `lib/core/theme/` - app_theme.dart, app_colors.dart, app_typography.dart
- [ ] `lib/core/routes/` - app_router.dart, route_names.dart
- [ ] `lib/core/constants/` - api_constants.dart, app_constants.dart
- [ ] `lib/core/utils/` - result.dart (Result<T> sealed class)
- [ ] `lib/di/` - injection_container.dart
- [ ] `lib/features/` 하위 10개 모듈 폴더 생성 (각각 domain/data/presentation)
- [ ] `lib/shared/widgets/`, `lib/shared/providers/`
- [ ] `test/features/`, `test/fixtures/`, `test/mocks/`
- **완료 기준**: 모든 폴더가 존재하고 빈 .gitkeep 또는 기본 파일 배치

## 0-3. pubspec.yaml 패키지 설정
- [ ] 상태관리: `flutter_riverpod`, `riverpod_annotation`
- [ ] DI: `get_it`, `injectable`, `injectable_generator`
- [ ] 네트워크: `dio`
- [ ] 로컬DB: `hive`, `hive_flutter`
- [ ] 라우팅: `go_router`
- [ ] 이미지: `image_picker`, `image`
- [ ] 유틸: `path_provider`, `share_plus`, `permission_handler`
- [ ] 분석: `firebase_core`, `firebase_analytics`
- [ ] dev: `build_runner`, `mockito`, `flutter_lints`
- [ ] `flutter pub get` 성공
- **완료 기준**: 빌드 에러 없이 `flutter pub get` 통과

## 0-4. Core 레이어 구현
- [ ] `result.dart`: Result<T> sealed class (Success/Failure)
- [ ] `failures.dart`: AppFailure 추상 클래스 + NetworkFailure, ServerFailure, AIGenerationFailure, StorageFailure
- [ ] `exceptions.dart`: 커스텀 예외 클래스
- [ ] `api_client.dart`: Dio 래퍼 (base URL, 인터셉터, 타임아웃 30초)
- [ ] `network_info.dart`: 네트워크 연결 상태 확인
- [ ] `app_theme.dart`: MaterialApp 테마 (다크/라이트)
- [ ] `app_colors.dart`: 앱 컬러 팔레트
- [ ] `app_typography.dart`: 애니 폰트 스타일 정의 (옐로우+블랙 아웃라인)
- [ ] `app_router.dart`: GoRouter 기본 라우트 (홈, 갤러리, 설정)
- **완료 기준**: Core 클래스에 대한 unit test 통과

## 0-5. DI 컨테이너 + Mock 주입
- [ ] `injection_container.dart`: get_it 설정
- [ ] 10개 모듈 각각의 Mock 구현체 등록
  - MockImageGenRepository (원본 반환)
  - MockTitleRepository (샘플 자막 반환)
  - MockScratchConfig (스크래치 없이 즉시 표시)
  - MockWatermarkRepository (텍스트만 합성, 워터마크 없음)
  - MockAdManager (즉시 콜백)
  - MockBillingService (모든 권한 열림)
  - MockAnalyticsTracker (콘솔 로그)
  - 나머지는 Real 구현
- [ ] 환경 분기: dev/staging/prod 설정
- **완료 기준**: 모든 Mock이 주입된 상태로 앱 빌드 성공

## 0-6. CI 기본 설정
- [ ] `analysis_options.yaml` 린트 규칙
- [ ] `.gitignore` 설정
- [ ] git init + 초기 커밋
- **완료 기준**: `flutter analyze` 경고 0개
