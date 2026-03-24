# Anime Title Academy 인수인계 문서 (2026-03-21)

## 문서 목적
- 새 섹션에서 바로 작업을 이어갈 수 있도록 현재 앱 상태, 최근 변경 사항, 확정 정책, 다음 구현 우선순위를 정리한다.
- 다음 세션의 1순위 작업은 `보상형 광고 기반 무료 이용권 시스템 구현`이다.

## 현재 브랜치 / 작업 맥락
- 작업 브랜치: `codex/gptRefactor`
- 최근 리팩토링과 기능 수정은 이 브랜치 위에서 진행되었다.
- Windows는 개발/검증용으로 계속 사용 중이며, 광고 기능은 최종적으로 모바일/웹 중심으로 고려한다.

## 현재 앱 핵심 구조
- 앱 경로:
  - `E:\Study\Rootfolio\AppRoot\anime_title_academy`
- 현재 핵심 생성 흐름:
  1. 이미지 선택
  2. 스타일 선택
  3. Vision으로 태그 추출
  4. LLM으로 제목 생성
  5. 스크래치 UX로 결과 노출

## 최근 주요 코드 변경 사항

### 1. LLM 모델 선택 UI 추가
- 결과 화면에 드롭다운형 모델 선택 버튼 추가됨.
- 위치: `다시하기` 버튼 위.
- 선택지:
  - `빠름` -> `gemini-2.5-flash-lite`
  - `밸런스` -> `gemini-2.5-flash`
  - `고품질` -> `gemini-2.5-pro`
- 관련 파일:
  - [result_page.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\features\title_academy\presentation\result_page.dart)
  - [title_provider.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\features\title_academy\presentation\title_provider.dart)
  - [title_generation_model.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\features\title_academy\domain\title_generation_model.dart)
  - [ai_client.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\core\network\ai_client.dart)
  - [gemini_api_key_client.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\core\network\gemini_api_key_client.dart)

### 2. LLM 기본 모델 변경
- 기본 LLM fallback은 `gemini-2.5-flash-lite`로 변경됨.
- `.env`에 `GEMINI_LLM_MODEL`을 넣으면 그 값이 우선한다.
- 관련 파일:
  - [app_config.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\core\config\app_config.dart)

### 3. 스크래치 꽃가루 이펙트 이벤트 기반 트리거로 변경
- 기존에는 `isCleared` 불리언 전환 기반이라 가끔 이펙트 재생이 누락되는 문제가 있었다.
- 현재는 `revealEventId` 증가 기반 이벤트 트리거로 변경됨.
- 저장 버튼 활성화 기준인 `isCleared`는 유지하고, 꽃가루만 별도 이벤트로 분리했다.
- 관련 파일:
  - [scratch_provider.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\features\scratch_ux\presentation\scratch_provider.dart)
  - [scratch_wrapper_view.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\features\scratch_ux\presentation\scratch_wrapper_view.dart)
  - [reveal_particle.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\features\scratch_ux\presentation\reveal_particle.dart)

### 4. 성능 로그와 캐시 관련 상태
- Vision/LLM 병목 확인용 디버그 타이밍 로그가 들어가 있다.
- 현재 확인된 결론:
  - `자막만 다시 생성`은 실제로 Vision을 재호출하지 않는다.
  - 체감 병목은 주로 `llm_generation`이다.
- 관련 로그 키:
  - `vision_prepare`
  - `vision_api_call`
  - `vision_analysis`
  - `vision_analysis cache hit`
  - `llm_generation`
  - `title_pipeline_total`

### 5. 다양성 개선 로직
- Vision 태그 중 1~2개를 랜덤 핵심 태그로 선택해 프롬프트에 강조한다.
- `다시하기`와 `자막만 다시 생성`은 최근 제목을 프롬프트에 넣어 표현 반복을 줄이도록 되어 있다.
- 관련 파일:
  - [prompt_template_service.dart](E:\Study\Rootfolio\AppRoot\anime_title_academy\lib\features\title_academy\data\prompt_template_service.dart)

## 광고 관련 확정 정책

### 1. 광고 구조
- 메인 수익화 방식은 `보상형 광고`로 간다.
- 현재 시점에서는 `전면광고`를 메인 구조에 넣지 않는다.
- 배너광고는 후순위이며, 현재 구현 대상이 아니다.

### 2. 모델별 일일 무료 횟수
- `빠름`: 5회
- `밸런스`: 3회
- `고품질`: 1회

### 3. 광고 1회당 충전 횟수
- `빠름`: 3회
- `밸런스`: 2회
- `고품질`: 2회

### 4. 초기화 정책
- 매일 `00:00`에 초기화
- 무료 이용권뿐 아니라 광고로 충전된 잔여량도 함께 초기화

### 5. 광고 실패 정책
- 광고 로드 실패 / 재생 실패 / 사용자 중도 종료 시 충전 없음

### 6. 개발모드 정책
- 개발모드에서는 광고를 띄우지 않음
- 개발모드에서는 무료 횟수 제한도 무시
- 즉 개발모드에서는 광고 없이 앱이 정상 기동되고 모든 모델을 자유롭게 테스트할 수 있어야 함

### 7. 저장소 결정
- 무료 사용량 / 충전량 / 마지막 리셋 날짜 저장은 `shared_preferences` 사용

### 8. 광고 성공 후 동작
- 광고 시청 성공 직후, 현재 요청한 생성 흐름을 자동 재개
- 사용자가 버튼을 다시 누를 필요 없음

## 이미 작성된 관련 문서
- 제품 기획서:
  - [rewarded_ad_quota_product_plan.md](E:\Study\Rootfolio\AppRoot\anime_title_academy\docs\planning\rewarded_ad_quota_product_plan.md)
- 구현 계획서:
  - [rewarded_ad_quota_implementation_plan.md](E:\Study\Rootfolio\AppRoot\anime_title_academy\docs\planning\rewarded_ad_quota_implementation_plan.md)
- 고품질 로딩 UX 아이디어:
  - [high_quality_loading_ux_ideas.md](E:\Study\Rootfolio\AppRoot\anime_title_academy\docs\ideas\high_quality_loading_ux_ideas.md)
- 사용자 각자 비용 부담 구조 검토:
  - [user_pays_gemini_usage_options.md](E:\Study\Rootfolio\AppRoot\anime_title_academy\docs\ideas\user_pays_gemini_usage_options.md)

## 다음 세션 권장 작업 순서
1. `shared_preferences` 의존성 확인 및 사용량 저장 구조 추가
2. `usage_quota_constants.dart` 신설
3. 모델별 quota 도메인 모델 / 로컬 datasource / service 구현
4. `AdService` 추상화 추가
5. 개발모드용 `NoopAdService` 구현
6. 결과 화면에 남은 무료 횟수 / 충전 잔여량 표시
7. `다시하기` / `자막만 다시 생성` 직전에 quota 검사 연결
8. quota 부족 시 보상형 광고 다이얼로그 및 성공 후 자동 재개 연결
9. 테스트 작성

## 구현 시 주의사항
- 광고 SDK 코드를 UI에 직접 넣지 말 것
- 정책 수치를 하드코딩하지 말고 상수 파일로 분리할 것
- 개발모드에서는 광고 모듈이 없어도 앱이 정상 작동해야 함
- `title_academy` feature 내부 책임을 유지하고, 공통 관심사는 `core`로만 올릴 것
- 기존 모델 선택 UI와 충돌하지 않게 quota 시스템은 현재 선택 모델을 기준으로 동작해야 함

## 현재 검증 상태
- `dart analyze`: 에러 없음, info-level 경고만 남아 있음
- `flutter test`: 통과

## 남은 결정 사항
- 광고 SDK 최종 선택
- 광고 단위 ID 관리 방식
- 결과 화면 잔여량 표시 문구와 레이아웃 상세안

## 한 줄 요약
- 현재 앱은 모델 선택, 스크래치 이펙트 안정화, LLM 경로 정리가 끝난 상태다.
- 다음 세션은 `보상형 광고 + 일일 무료 이용권 + shared_preferences 저장 + 개발모드 광고 우회` 구현으로 바로 들어가면 된다.
