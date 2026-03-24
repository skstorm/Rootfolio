# 보상형 광고 SDK 연동 실행 계획서

작성일: 2026-03-24

## 문서 목적
- 현재의 가짜 테스트 광고 성공 처리 구조를 종료하고, 실제 광고 SDK를 앱에 연결한다.
- 우선 Android 모바일 환경에서 `테스트 광고 ID` 기준으로 검증 가능한 상태를 만든다.
- 이후 실광고 ID로 교체할 수 있도록 구조를 분리한다.

## 현재 상태
- quota 정책은 구현되어 있다.
- 결과 화면에서 무료 횟수 부족 시 광고 유도 다이얼로그가 뜬다.
- 광고 성공 후 quota 충전 및 자동 재개 흐름도 연결되어 있다.
- 하지만 현재 광고 서비스는 실제 SDK를 붙이지 않았다.
- `test` 모드는 성공만 흉내 내는 `TestRewardedAdService`다.
- `production` 모드는 placeholder이며 실제 광고를 띄우지 않는다.

## 이번 작업의 목표
- Android 디버그 빌드에서 실제 테스트 보상형 광고가 뜨게 만든다.
- 광고 완료 시 quota 충전 후 현재 요청 흐름이 자동 재개되게 만든다.
- 광고 닫기, 로드 실패, 표시 실패, 보상 미지급 시 충전되지 않게 만든다.
- `disabled / test / production` 모드를 계속 유지한다.
- `test`와 `production`의 차이는 광고 단위 ID와 운영 모드에서만 나게 만든다.

## 범위
### 포함
- `google_mobile_ads` 기반 보상형 광고 SDK 연결
- Android 우선 지원
- 테스트 광고 ID 연동
- 런타임 모드별 광고 서비스 연결
- 수동 검증 체크리스트 작성

### 제외
- iOS 실기기 검증
- 전면광고 / 배너광고
- 원격 설정
- 실광고 ID 발급 및 운영 정책 최종 확정

## 설계 원칙
### 1. 광고 SDK 코드는 UI에 넣지 않는다
- UI는 `AdService`만 호출한다.
- 광고 SDK 구현 상세는 `core/ads` 안에만 둔다.

### 2. 테스트 광고와 실광고는 런타임 모드로 분리한다
- `disabled`: 광고 호출 안 함
- `test`: 실제 SDK 호출 + 테스트 광고 ID
- `production`: 실제 SDK 호출 + 실광고 ID

### 3. 디버그 우회와 광고 모드는 분리한다
- 일반 디버그 실행은 여전히 quota/ad 우회
- `FORCE_QUOTA_AND_ADS=true`이면 디버그에서도 실제 정책 적용
- 이때 `REWARDED_AD_MODE=test`면 테스트 광고를 띄운다

### 4. 보상 지급 기준은 SDK의 보상 콜백이다
- 광고가 보였다는 사실만으로 충전하면 안 된다.
- `onUserEarnedReward`가 발생했을 때만 quota를 충전한다.

## 권장 최종 구조
### core
- `lib/core/ads/ad_service.dart`
- `lib/core/ads/ad_runtime_mode.dart`
- `lib/core/ads/noop_ad_service.dart`
- `lib/core/ads/google_rewarded_ad_service.dart`
- `lib/core/constants/ad_unit_constants.dart`
- `lib/core/config/app_runtime_config.dart`

### title_academy
- `lib/features/title_academy/presentation/result_page.dart`
- `lib/features/title_academy/presentation/title_provider.dart`
- `lib/features/title_academy/domain/title_usage_quota_service.dart`

### platform
- `android/app/src/main/AndroidManifest.xml`
- 필요 시 iOS `Info.plist`

## 단계별 실행 계획

## 1. 의존성 및 SDK 초기화 추가
### 목표
- 앱이 Android에서 Mobile Ads SDK를 초기화할 수 있게 만든다.

### 작업
- `pubspec.yaml`에 `google_mobile_ads` 추가
- Android Manifest에 Mobile Ads `APPLICATION_ID` 메타데이터 추가
- 앱 시작 시 Android/iOS에서만 SDK 초기화
- Windows/Web에서는 광고 SDK 초기화를 하지 않음

### 구현 메모
- `main.dart`에 직접 모든 초기화 로직을 넣지 말고 별도 bootstrap/helper로 분리하는 편이 좋다.
- 예시 파일:
  - `lib/core/ads/mobile_ads_bootstrap.dart`

### 완료 기준
- Android 실행 시 앱이 광고 SDK 초기화 때문에 크래시 나지 않는다.

## 2. 광고 단위 ID 관리 파일 추가
### 목표
- 테스트 광고 ID와 실광고 ID를 한 파일에서 관리한다.

### 작업
- `lib/core/constants/ad_unit_constants.dart` 추가
- Android/iOS 분기 함수 또는 getter 정의
- 테스트 광고 ID와 프로덕션 광고 ID 선택 책임을 한 곳에 모음

### 원칙
- 광고 단위 ID 문자열을 서비스 내부에 직접 박지 않는다.
- UI에서 광고 단위 ID를 알지 못하게 한다.

### 권장 구조 예시
- `getRewardedAdUnitId(RewardedAdMode mode)`
- 내부에서 `Platform.isAndroid`, `Platform.isIOS` 분기
- `test`면 공식 테스트 광고 ID 반환
- `production`이면 실제 광고 ID 반환

## 3. 실제 SDK 기반 광고 서비스 구현
### 목표
- 현재의 `TestRewardedAdService`, `ProductionRewardedAdService`를 실제 SDK 구현으로 대체한다.

### 작업
- `lib/core/ads/google_rewarded_ad_service.dart` 추가
- `RewardedAd.load` 사용
- 로드 성공/실패 콜백 처리
- 전체 화면 표시 콜백 처리
- 보상 지급 콜백 처리
- 광고 dispose 처리

### 권장 동작
- `showRewardedAd()` 호출 시:
  1. 적절한 광고 단위 ID 선택
  2. 광고 로드
  3. 로드 실패 시 `unavailable` 반환
  4. 로드 성공 시 `show()`
  5. `onUserEarnedReward` 발생 시 내부 `earnedReward = true`
  6. 광고 닫힘 시:
     - `earnedReward == true`면 `rewarded`
     - 아니면 `dismissed`
  7. 표시 실패 시 `unavailable`

### 주의사항
- `show()`가 호출됐다고 보상이 지급된 것은 아니다.
- 충전 여부는 반드시 보상 콜백 기준으로 결정한다.
- `onAdDismissedFullScreenContent`와 `onUserEarnedReward` 순서 차이를 고려해 내부 상태 플래그를 둔다.
- 광고 객체는 성공/실패/닫힘 어느 경로든 dispose 해야 한다.

## 4. DI 매핑 정리
### 목표
- 런타임 모드에 따라 적절한 광고 서비스가 주입되게 만든다.

### 작업
- `injection_container.dart` 수정
- 매핑 규칙:
  - `disabled -> NoopAdService`
  - `test -> GoogleRewardedAdService`
  - `production -> GoogleRewardedAdService`

### 구현 메모
- `GoogleRewardedAdService`는 mode를 생성자 또는 config로 받아 내부에서 광고 단위 ID를 고르게 한다.
- 서비스 클래스는 하나로 유지하고, 모드 차이는 config에서 처리하는 편이 낫다.

## 5. 현재 UI 흐름 유지 및 보강
### 목표
- 현재 quota 다이얼로그 및 자동 재개 흐름은 그대로 두고, 실제 광고 SDK와 연결한다.

### 작업
- `result_page.dart`에서 광고 요청 전후 중복 탭 방지 유지
- 광고 실패 문구를 좀 더 구체화
- 디버그에서 `test` 모드일 때는 안내 문구를 보여주되, 흐름 자체는 실제 광고 SDK를 타게 함

### 체크 포인트
- 무료 횟수 남아 있을 때는 광고를 띄우지 않음
- 무료 횟수 소진 시 광고 유도 다이얼로그 표시
- 광고 완료 시 quota 충전 후 자동 재개
- 광고 닫기/실패 시 충전 없음

## 6. Android 수동 검증
### 실행 명령
```powershell
flutter run -d android --dart-define=FORCE_QUOTA_AND_ADS=true --dart-define=REWARDED_AD_MODE=test
```

### 검증 순서
1. Android 에뮬레이터 또는 실기기에서 앱 실행
2. 결과 화면 진입
3. 모델 하나 선택 후 무료 횟수를 모두 소진
4. 광고 유도 다이얼로그 확인
5. `광고 보고 충전` 탭
6. 실제 테스트 보상형 광고가 뜨는지 확인
7. 광고 완료 후 quota 충전 및 자동 재개 확인
8. 결과 화면의 무료/충전 잔여량 표시 확인

### 실패 시나리오 확인
1. 광고를 중간에 닫았을 때 충전되지 않는지
2. 광고 로드 실패 시 충전되지 않는지
3. 광고 표시에 실패했을 때 다시 시도 가능한지

### 모델별 확인
- `빠름`: 광고 1회 후 3회 충전되는지
- `밸런스`: 광고 1회 후 2회 충전되는지
- `고품질`: 광고 1회 후 2회 충전되는지

## 7. 테스트 보강
### 단위 테스트
- ad mode별 서비스 선택
- 모드별 광고 단위 ID 선택
- 보상 획득 시 `rewarded`
- 닫기만 하고 보상 없으면 `dismissed`
- 로드 실패/표시 실패 시 `unavailable`

### 수동 검증 우선순위
- 광고 SDK lifecycle은 단위 테스트만으로 충분하지 않다.
- Android 실기기 또는 에뮬레이터에서 수동 검증 체크리스트를 반드시 수행한다.

## 8. 완료 기준
- Android 디버그 빌드에서 실제 테스트 보상형 광고가 표시된다.
- 광고 완료 시 quota가 충전되고 요청 흐름이 자동 재개된다.
- 광고 실패/닫기 시 quota가 충전되지 않는다.
- `disabled / test / production` 모드가 유지된다.
- 테스트 광고 ID를 실광고 ID로 쉽게 교체할 수 있다.

## 구현 시 수정 대상 파일 후보
- [pubspec.yaml](/E:/Study/Rootfolio/AppRoot/anime_title_academy/pubspec.yaml)
- [main.dart](/E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/main.dart)
- [app_runtime_config.dart](/E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/core/config/app_runtime_config.dart)
- [ad_service.dart](/E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/core/ads/ad_service.dart)
- [ad_runtime_mode.dart](/E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/core/ads/ad_runtime_mode.dart)
- [noop_ad_service.dart](/E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/core/ads/noop_ad_service.dart)
- [injection_container.dart](/E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/di/injection_container.dart)
- [result_page.dart](/E:/Study/Rootfolio/AppRoot/anime_title_academy/lib/features/title_academy/presentation/result_page.dart)
- [AndroidManifest.xml](/E:/Study/Rootfolio/AppRoot/anime_title_academy/android/app/src/main/AndroidManifest.xml)

## 모델 / 이성레벨 운용 가이드
### 기본 원칙
- 설계와 예외 케이스 정리는 높은 reasoning으로 끝낸다.
- 구현과 테스트는 같은 모델 계열에서 낮은 reasoning으로 내리는 편이 효율적이다.
- 한 문제를 푸는 중간에는 모델이나 reasoning을 자주 바꾸지 않는다.
- 단계 경계에서만 바꾼다.

### 권장 조합
#### A. 설계 확정 단계
- 추천: `gpt-5.3-codex high`
- 목적: 광고 lifecycle, 상태 전이, DI 구조, 플랫폼 예외 정리

#### B. SDK 연결 및 Android 설정
- 추천: `gpt-5.3-codex high`
- 이유: 플랫폼 설정과 SDK 이벤트 처리는 작은 실수가 크래시로 이어질 수 있다.

#### C. 서비스 구현 및 UI 연결
- 추천: `gpt-5.3-codex medium`
- 이유: 방향이 정해진 뒤의 구현 작업은 속도와 일관성이 중요하다.

#### D. 테스트 및 정리
- 추천: `gpt-5.3-codex medium`
- 필요 시 예외 케이스 정리는 `high`

### 섹션 안에서 모델/이성레벨을 바꾸는 디메리트
- 방금 정한 책임 분리 기준이 흔들릴 수 있다.
- 코드 스타일이 바뀌면서 리팩터링이 불필요하게 늘어날 수 있다.
- 직전 판단의 암묵적 전제를 새 모델이 놓칠 수 있다.
- 같은 문제를 다시 설명하는 비용이 생긴다.

### 결론
- 섹션 안에서 자주 바꾸는 것은 비효율적이다.
- 하지만 섹션이 바뀌는 시점에 `high -> medium`으로 내리는 것은 실용적이다.
- 이번 작업은 `설계/플랫폼 설정 = high`, `실제 구현/테스트 = medium`이 가장 무난하다.

## 구현 시작 순서 제안
1. `google_mobile_ads` 의존성 추가
2. Android Manifest 설정
3. 광고 단위 ID 상수 파일 추가
4. `GoogleRewardedAdService` 구현
5. DI 매핑 교체
6. Android 디버그 + 테스트 광고 검증
7. 실패 케이스 수동 검증
8. 테스트 보강

## 한 줄 요약
- 다음 구현의 핵심은 가짜 테스트 광고를 없애고, Android에서 실제 테스트 보상형 광고가 뜨는 구조로 바꾸는 것이다.
- 구현은 `gpt-5.3-codex` 중심으로 진행하되, 설계/플랫폼 설정은 `high`, 실제 코드 작성은 `medium`으로 나누는 것이 효율적이다.
