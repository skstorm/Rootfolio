# Anime Title Academy 구조 분석 보고서 및 리팩토링 계획서

## 1. 프로젝트 이해 요약

**Anime Title Academy**는 사용자 사진에 AI가 유머러스한 애니메이션 스타일 자막을 생성해주는 Flutter 앱입니다.
결과물은 스크래치(Scratcher) 인터랙션으로 공개되며, 보상형 광고 + 인앱결제 수익모델을 갖추고 있습니다.

4개 핵심 모듈(ImageGen, TitleAcademy, ScratchUX, AdManager)을 인터페이스 기반으로 분리한 Clean Architecture를 지향합니다.

### 현재 진행 상태 (3/12 ~ 3/24 워크로그 기반)
| Phase | 상태 | 비고 |
|---|---|---|
| Phase 0: 프로젝트 기반 | ✅ 완료 | Clean Architecture, DI, 라우팅 |
| Phase 1: MVP 코어 엔진 | ✅ 완료 | Gemini Vision+LLM 연동, 프롬프트 관리 시스템 |
| Phase 2: 스크래치 UX | ✅ 완료 | 점진적 스크래치, 파티클 이펙트, 디버그 시스템 |
| Phase 3: AI 이미지 변환 | 🔧 구조만 구현 | SD API datasource 존재, 실 연동 미완 |
| Phase 4: 수익화 | ✅ 1차 완료 | 보상형 광고 quota 시스템, AdMob SDK 연동 |

---

## 2. 구조적 문제점 분석

### 🔴 심각도: 높음

#### 2-1. DI 체계의 이중 혼재 (GetIt + Injectable + 수동 등록)

[injection_container.dart](file:///E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/di/injection_container.dart)에서 `@InjectableInit`으로 자동 생성된 DI와 수동 `registerSingleton`/`registerLazySingleton`이 혼재합니다.

```dart
// 자동 생성 DI
getIt.init(environment: env);

// 수동 등록 (총 4건)
getIt.registerSingleton<AppRuntimeConfig>(...);
getIt.registerSingleton<SharedPreferences>(...);
getIt.registerLazySingleton<TitleUsageLocalDatasource>(...);
getIt.registerLazySingleton<TitleUsageQuotaService>(...);
getIt.registerLazySingleton<AdService>(...);
```

**문제**: `injectable` module로 옮기면 `build_runner` 한 방으로 DI 그래프 전체를 관리할 수 있는데, 수동 등록이 섞여 있으면:
- 등록 순서 오류 위험
- 테스트에서 mock 주입이 어려움
- DI 의존관계를 한 눈에 파악 불가

**제안**: `di/modules/` 디렉터리에 `@module` 어노테이션 클래스를 만들어 `SharedPreferences`, `AppRuntimeConfig`, `AdService` 등을 모듈로 이전.

---

#### 2-2. `ApiConstants`에 하드코딩된 API 키 잔재

[api_constants.dart](file:///E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/core/constants/api_constants.dart):
```dart
static const String geminiApiKey = '여기에_GEMINI_API_KEY_입력';
```

`AppConfig`가 이미 `.env` 기반으로 키를 관리하고 있어, 이 상수는 **사용되지 않는 잔재**입니다. 그러나 존재 자체가:
- 실수로 참조될 위험
- 3/18 작업일지의 "API 키 보안 유출 사고"와 같은 재발 가능성

**제안**: `ApiConstants` 파일에서 `geminiApiKey` 필드를 삭제하고, base URL만 남기거나 `AppConfig`로 통합.

---

#### 2-3. `ResultPage` 466줄의 God Widget 문제

[result_page.dart](file:///E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/features/title_academy/presentation/result_page.dart)(466줄)에 다음이 모두 포함:
- quota 로직 (`_executeWithQuota`, `_showQuotaDialog`)
- 광고 호출 로직 (`adServiceProvider.showRewardedAd`)
- UI 렌더링 (이미지, 스크래치, 버튼 3종, 디버그 토글)
- LLM 모델 선택 UI
- quota 요약 UI (`_buildQuotaSummary`)

**문제**: 비즈니스 로직(quota 소비/충전/광고 호출)이 presentation 위젯 안에 직접 존재하여:
- 단위 테스트 불가
- 로직 변경 시 UI 파일 전체를 건드려야 함
- 코드 리뷰/유지보수 난이도 증가

**제안**: `QuotaGatedPipelineService`(또는 UseCase)를 분리하여 "quota 확인 → 광고 → 충전 → 실행" 오케스트레이션을 도메인 레이어로 이동. `ResultPage`는 provider를 watch하여 UI만 담당.

---

### 🟡 심각도: 중간

#### 2-4. 상수 관련 중복 및 분산

| 상수 | 위치 1 | 위치 2 |
|---|---|---|
| 스크래치 threshold | `AppConstants.scratchThreshold = 0.4` | `UiConstants.scratchTotalClearThreshold = 0.2` |
| 디버그 표시 여부 | `UiConstants.showDebugHitGrids` | `DebugService.isDebugMode` |
| AI 관련 상수 | `AiConstants` (2개만) | 프롬프트 관련 상수는 `PromptTemplateService` 내부에 분산 |

**문제**: 같은 개념의 값이 다른 파일에 다른 이름으로 존재 → 어떤 값이 실제 동작하는지 추적 어려움.

**제안**:
- `AppConstants.scratchThreshold`(사용되지 않는 값)를 삭제
- 상수 파일을 **도메인별**로 재구성: `scratch_constants.dart`, `ai_pipeline_constants.dart`, `quota_constants.dart`

---

#### 2-5. `core/util` vs `core/utils` 디렉터리 중복

- `core/util/` → `debug_service.dart` (210줄의 거대 파일)
- `core/utils/` → `result.dart` (1개 파일)

**문제**: 네이밍 불일치로 새 유틸리티를 어디에 둬야 할지 혼란.

**제안**: `core/utils/`로 단일화. `debug_service.dart`는 역할 분리 후 적절한 위치로 이동.

---

#### 2-6. `DebugService` 단일 파일에 과도한 책임 집중

[debug_service.dart](file:///E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/core/util/debug_service.dart)(210줄)에 포함된 것:
- 추상 인터페이스 (`DebugService`)
- 개발/릴리스 구현체 (`DevelopmentDebugService`, `ReleaseDebugService`)
- Riverpod Notifier (`DebugEnabledNotifier`)
- Riverpod Provider 2개 (`debugEnabledProvider`, `debugServiceProvider`)
- 디버그 오버레이 위젯 빌드 로직 (약 70줄)

**문제**: 인터페이스, 구현체, 상태관리, UI가 한 파일에 모여 있어 수정 영향 범위가 넓음.

**제안**: 분리 구조:
- `core/debug/debug_service.dart` → 인터페이스 + static 유틸
- `core/debug/dev_debug_service.dart` → 개발 모드 구현체
- `core/debug/release_debug_service.dart` → 릴리스 모드 구현체
- `shared/providers/debug_provider.dart` → Notifier + Provider
- `shared/widgets/debug_overlay.dart` → 오버레이 위젯

---

#### 2-7. `ad_manager` / `billing` 빈 feature 디렉터리

`features/ad_manager/`와 `features/billing/`이 존재하지만 내부에 dart 파일이 0개입니다. 반면 실제 광고 로직은 `core/ads/`에 7개 파일로 구현되어 있습니다.

**문제**: 기획서의 4대 모듈 중 하나인 "AdManager"가 feature로 존재하지 않고 core에 구현 → 아키텍처 문서와 실제 코드의 불일치.

**제안**:
- 빈 디렉터리 삭제 또는
- `core/ads/` 내용을 `features/ad_manager/`로 이동하여 아키텍처 문서와 정합성 확보

---

### 🟢 심각도: 낮음 (개선 권장)

#### 2-8. GetIt과 Riverpod의 이중 DI 사용

현재 프로젝트는 **GetIt**(서비스 레이어)과 **Riverpod**(UI 상태관리)를 동시에 사용합니다.

```dart
// debug_service.dart에서 GetIt을 직접 참조
final logger = getIt<AppLogger>();
```

**문제**: 두 DI 시스템 사이의 브릿지 코드가 필요하고, 의존성 추적이 분산됨.

**제안**: 장기적으로 Riverpod 단일화를 고려. 단, 현재 injectable/GetIt 기반 구조가 이미 정착되어 있으므로 급진적 변경보다는 **새로운 코드에서는 Riverpod provider 우선** 원칙을 적용.

---

#### 2-9. 테스트 커버리지의 편중

현재 테스트 6개:
| 테스트 | 테스트 대상 |
|---|---|
| `ad_unit_constants_test.dart` | 광고 단위 ID 해석 |
| `app_runtime_config_test.dart` | 런타임 설정 해석 |
| `gemini_vision_datasource_test.dart` | Vision API 호출 |
| `prompt_template_service_test.dart` | 프롬프트 조합 |
| `title_repository_impl_test.dart` | 제목 생성 레포지토리 |
| `title_usage_quota_service_test.dart` | 사용량 quota 서비스 |

**누락 영역**:
- `ScratchPainter` / `ScratchCanvas` 유닛 테스트 없음
- `DebugService` 구현체 테스트 없음
- `ImageGenRepository`(NSFW 체크, 폴백 로직) 테스트 없음
- Widget 테스트 전무

**제안**: 리팩토링 후 새로 분리된 서비스(`QuotaGatedPipelineService` 등)에 대한 테스트를 우선 추가.

---

#### 2-10. `.env` 파일이 pubspec assets에 포함

```yaml
assets:
  - .env
```

`.env` 파일을 Flutter assets로 번들링하면 APK/IPA 내부에 API 키가 평문으로 포함됩니다.

**제안**: 릴리스 빌드 시에는 `--dart-define`이나 서버 프록시를 통한 키 전달로 전환 검토. 개발 편의를 위해 현재 구조를 유지하더라도, `.env.example`과 주석을 통해 릴리스 전환 가이드를 명시.

---

## 3. 리팩토링 우선순위 제안

| 순위 | 항목 | 영향도 | 난이도 | 비고 |
|:---:|---|:---:|:---:|---|
| 1 | `ApiConstants` 하드코딩 키 제거 | 🔴 보안 | ⭐ | 5분 작업 |
| 2 | `AppConstants` 중복 상수 정리 | 🟡 혼란 방지 | ⭐ | 10분 작업 |
| 3 | `core/util` → `core/utils` 통합 | 🟡 일관성 | ⭐ | 경로 변경 + import 수정 |
| 4 | 빈 feature 디렉터리 정리 | 🟢 정돈 | ⭐ | 삭제 or 이동 결정 필요 |
| 5 | `DebugService` 파일 분리 | 🟡 유지보수성 | ⭐⭐ | 5개 파일로 분리 |
| 6 | `ResultPage` 비즈니스 로직 분리 | 🔴 테스트 가능성 | ⭐⭐⭐ | UseCase/Service 추출 |
| 7 | DI 수동 등록 → injectable module 이전 | 🔴 DI 일관성 | ⭐⭐ | `@module` 클래스 작성 |
| 8 | 상수 파일 도메인별 재구성 | 🟡 가독성 | ⭐⭐ | 기존 import 전부 수정 필요 |
| 9 | 테스트 추가 (분리된 서비스) | 🟡 안정성 | ⭐⭐ | 리팩토링 후 진행 |
| 10 | `.env` 보안 가이드 문서화 | 🟢 미래 대비 | ⭐ | 문서 작성 |

---

## 4. 추가 관점 제안

### 4-1. 빌드/배포 자동화

현재 빌드 명령이 `--dart-define` 인자가 길어 실수하기 쉽습니다:
```powershell
flutter run -d windows --dart-define=FORCE_QUOTA_AND_ADS=true --dart-define=REWARDED_AD_MODE=fake
```

**제안**: 
- `Makefile` 또는 `.vscode/launch.json`에 프로필별 빌드 설정을 사전 정의
- `scripts/run_dev.ps1`, `scripts/run_ad_test.ps1` 같은 래퍼 스크립트 작성

### 4-2. Feature 모듈 간 의존 방향 정리

현재 `result_page.dart`에서 `scratch_ux`, `title_academy`, `core/ads` 세 모듈을 직접 import합니다. 이상적으로는 feature 간 직접 참조를 줄이고, **shared provider** 또는 **중개 레이어**를 통해 연결하는 것이 좋습니다.

### 4-3. `withOpacity()` Deprecated 대응

`debug_service.dart`에서 `Colors.black.withOpacity(0.9)` 등을 사용하고 있습니다. Flutter 최신 버전에서 `withOpacity()`는 deprecated 경고가 발생할 수 있으므로, `Color.fromRGBO()` 또는 `withValues(alpha:)` 패턴으로 전환을 권장합니다.

---

## 5. 검증 계획

이 계획서는 **분석 보고서**이며, 실제 코드 변경을 포함하지 않습니다.
리팩토링 실행 시 아래 검증을 수행할 예정입니다:

### 자동 테스트
```bash
# 기존 6개 테스트 통과 확인
flutter test
```

### 정적 분석
```bash
# 분석 오류 0건 확인
flutter analyze
```

### 수동 검증
- Windows에서 `flutter run -d windows`로 앱 기동 후 전체 UX 플로우(홈 → 결과 → 스크래치 → 저장) 동작 확인
- 리팩토링 전후 동일한 동작 보장
