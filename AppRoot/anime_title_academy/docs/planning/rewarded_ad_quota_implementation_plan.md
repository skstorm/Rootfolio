# 보상형 광고 기반 무료 이용권 구현 계획서

## 문서 목적
- `무료 이용권 + 보상형 광고 충전` 구조를 현재 `anime_title_academy` 코드베이스에 어떻게 반영할지 기술적으로 정리한다.
- 개발모드에서는 광고 없이 기동되고, 릴리스 모드에서는 광고 모듈이 연결되도록 설계한다.

## 구현 목표
- 모델별 일일 무료 횟수 관리
- 모델별 광고 충전 횟수 관리
- `shared_preferences` 기반 로컬 저장
- 개발모드 광고 비활성화
- 광고 SDK 유무와 무관하게 앱이 기동 가능한 구조

## 설계 원칙

### 1. 광고는 추상화한다
- 광고 SDK 코드를 UI나 provider에 직접 넣지 않는다.
- `AdService` 인터페이스를 두고 구현체를 교체 가능하게 만든다.

### 2. 사용량 관리는 별도 서비스로 분리한다
- 무료 횟수, 충전 횟수, 날짜 초기화 로직은 `UsageQuotaService`에 모은다.
- 화면은 단순히 상태를 읽고 요청만 보낸다.

### 3. 정책 값은 상수 파일로 분리한다
- 무료 횟수, 충전량, 초기화 기준 관련 수치는 별도 파일에 둔다.
- 하드코딩을 금지한다.

### 4. 개발모드는 광고와 제한을 우회한다
- 디버그/개발 환경에서는 광고를 호출하지 않는다.
- 사용 제한도 적용하지 않는다.

## 제안 구조

### 1. 상수 / 설정 계층
- 파일 예시:
  - `lib/core/constants/usage_quota_constants.dart`
- 책임:
  - 모델별 일일 무료 횟수
  - 모델별 광고 1회당 충전량
  - 일일 리셋 기준 정보

예상 구조:
- `fastDailyFreeCount`
- `balancedDailyFreeCount`
- `highQualityDailyFreeCount`
- `fastRewardRechargeCount`
- `balancedRewardRechargeCount`
- `highQualityRewardRechargeCount`

또는 더 나은 방식:
- 모델 enum별 설정 객체 맵

### 2. 도메인 모델
- 파일 예시:
  - `lib/features/title_academy/domain/title_usage_quota.dart`
  - `lib/features/title_academy/domain/ad_reward_result.dart`
- 책임:
  - 모델별 남은 무료 횟수
  - 모델별 남은 충전 횟수
  - 마지막 리셋 날짜
  - 광고 시청 결과 표현

### 3. 저장소 계층
- 파일 예시:
  - `lib/features/title_academy/data/title_usage_local_datasource.dart`
  - `lib/features/title_academy/data/title_usage_repository_impl.dart`
- 책임:
  - `shared_preferences` 읽기/쓰기
  - 마지막 리셋 날짜 저장
  - 모델별 남은 무료/충전 횟수 저장

권장 저장 키 예시:
- `title_usage_last_reset_date`
- `title_usage_fast_free_used`
- `title_usage_fast_rewarded_remaining`
- `title_usage_balanced_free_used`
- `title_usage_balanced_rewarded_remaining`
- `title_usage_high_quality_free_used`
- `title_usage_high_quality_rewarded_remaining`

### 4. 사용량 서비스
- 파일 예시:
  - `lib/features/title_academy/domain/title_usage_quota_service.dart`
- 책임:
  - 현재 날짜 기준 초기화 필요 여부 판단
  - 특정 모델 사용 가능 여부 판단
  - 생성 시 무료/충전 횟수 차감
  - 광고 성공 시 충전 지급

핵심 메서드 예시:
- `Future<TitleUsageQuota> getQuota()`
- `Future<void> refreshIfNeeded()`
- `Future<QuotaConsumeResult> consume(TitleGenerationModel model)`
- `Future<void> reward(TitleGenerationModel model)`

### 5. 광고 서비스 추상화
- 파일 예시:
  - `lib/core/ads/ad_service.dart`
  - `lib/core/ads/noop_ad_service.dart`
  - `lib/core/ads/rewarded_ad_service.dart`
- 책임:
  - 보상형 광고 로드 / 시청 / 결과 반환

인터페이스 예시:
- `Future<AdRewardResult> showRewardedAd({required TitleGenerationModel model})`

구현 정책:
- `NoopAdService`
  - 개발모드 전용
  - 실제 광고를 띄우지 않음
  - 개발모드에서는 사용량 제한 자체를 무시하므로 실제 호출 빈도도 낮아야 함
- `RewardedAdService`
  - 릴리스 모드 전용
  - 실제 SDK 연동 담당

### 6. DI 연결
- 파일 예시:
  - `lib/di/injection_container.dart`
- 책임:
  - 개발모드: `NoopAdService`
  - 릴리스 모드: `RewardedAdService`
  - `UsageQuotaService` 및 로컬 datasource 등록

## UI 반영 계획

### 1. 결과 화면
- 현재 모델 선택 버튼 주변에 남은 횟수 표시 추가
- 표시 정보:
  - 오늘 무료 잔여
  - 광고 충전 잔여

예시:
- `빠름 3회 남음`
- `고품질 무료 0 / 충전 1`

### 2. 생성 시도 시 분기
- 사용 가능:
  - 즉시 생성
  - 사용권 1회 차감
- 사용 불가:
  - 보상형 광고 안내 다이얼로그 표시
  - 광고 성공 시 충전 지급
  - 광고 성공 직후 현재 요청한 생성을 자동 재개

### 3. 광고 안내 문구
- 예시:
  - `무료 횟수를 모두 사용했습니다`
  - `광고를 보면 고품질 2회를 충전할 수 있습니다`

### 4. 개발모드
- 사용량 안내 UI는 유지할 수 있으나, 실제 제한은 걸지 않는다.
- 또는 개발모드에서는 잔여량 표시 자체를 숨기는 것도 선택 가능하다.
- 1차 구현에서는 로직만 우회하고 UI는 유지하는 편이 검증에 유리하다.

## 로직 흐름

### 릴리스 모드 생성 흐름
1. 사용자가 모델 선택
2. `UsageQuotaService.refreshIfNeeded()` 호출
3. `consume(model)` 시도
4. 성공 시 생성 진행
5. 실패 시 광고 유도 UI 표시
6. 광고 성공 시 `reward(model)` 호출
7. 충전 성공 직후 현재 요청한 생성을 자동으로 재개

### 개발모드 생성 흐름
1. 사용자가 모델 선택
2. 사용 제한 검사 없이 생성 진행
3. 광고 호출 없음

## 초기화 정책
- 날짜 비교 기준은 로컬 날짜의 `yyyy-MM-dd` 문자열 또는 동등한 안전한 날짜 키를 사용한다.
- 현재 날짜와 마지막 저장 날짜가 다르면:
  - 무료 사용량 초기화
  - 광고 충전 잔여량도 함께 초기화

## 충전 잔여량 정책 제안
- 1차 구현 제안:
  - 광고로 충전된 잔여량도 날짜가 바뀌면 초기화
- 이유:
  - 일일 사용권 시스템이 단순해진다.
  - 악용 가능성이 줄어든다.
 - 상태:
   - 확정

## 테스트 계획

### 단위 테스트
- 날짜가 바뀌지 않으면 무료 횟수가 유지된다.
- 날짜가 바뀌면 무료 횟수가 초기화된다.
- 모델별 무료 횟수가 올바르게 차감된다.
- 무료 횟수 소진 후 충전 횟수가 있으면 충전 잔여량에서 차감된다.
- 광고 성공 시 모델별 충전량이 올바르게 지급된다.
- 광고 실패 시 충전되지 않는다.
- 개발모드에서는 사용량 제한이 적용되지 않는다.

### 위젯 테스트
- 남은 횟수가 결과 화면에 표시된다.
- 잔여량이 없을 때 광고 유도 UI가 표시된다.
- 광고 없는 개발모드에서도 화면이 정상 작동한다.

## 단계별 구현 순서
1. 상수 파일 추가
2. 도메인 모델과 저장 키 설계
3. `shared_preferences` 로컬 datasource 구현
4. `UsageQuotaService` 구현
5. `AdService` 추상화 및 `NoopAdService` 추가
6. DI 연결
7. 결과 화면 UI 표시 추가
8. 생성 흐름에 quota 검사 연결
9. 테스트 작성

## 미정 사항
- 광고 SDK 선택
- 광고 단위 ID 관리 방식

## 권장 후속 결정
1. 잔여량 표시 문구와 레이아웃 최종안 결정
