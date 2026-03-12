# Task List - Phase 1: MVP 코어 엔진

> 의존 관계: Phase 0 완료 필수
> 목표: 사진 → 프리셋 선택 → 자막 생성 → 결과 표시 → 저장/공유

---

## 1-1. TitleAcademy 모듈 (자막 생성) ★ 최우선
> 의존: Phase 0 (Core, DI)

### Domain
- [ ] `image_analysis.dart`: 분석 결과 엔티티 (tags, confidence)
- [ ] `title_result.dart`: 자막 결과 엔티티 (text, preset, timestamp)
- [ ] `title_repository.dart`: abstract class
- [ ] `analyze_image.dart`: UseCase
- [ ] `generate_title.dart`: UseCase

### Data
- [ ] `gemini_vision_datasource.dart`: Gemini Vision API 호출 → 태그 추출
- [ ] `gemini_llm_datasource.dart`: 태그 + 프리셋 → 자막 생성
- [ ] `vision_response_model.dart`, `llm_response_model.dart`
- [ ] `title_repository_impl.dart`: Real 구현
- [ ] `mock_title_repository.dart`: 샘플 자막 반환

### Presentation
- [ ] `title_provider.dart`: 상태 관리 (idle/loading/success/error)
- [ ] `preset_selector.dart`: 프리셋 선택 가로 스크롤 카드 UI

### 프롬프트 파일
- [ ] `assets/prompts/preset_documentary.txt`: 다큐멘터리 프롬프트
- [ ] `assets/prompts/preset_meme.txt`: 인터넷 밈 프롬프트
- [ ] `assets/prompts/preset_romance.txt`: 로맨스 프롬프트

### 테스트
- [ ] Vision API 응답 파싱 테스트 (fixtures/vision_response.json)
- [ ] LLM 응답 파싱 테스트 (fixtures/llm_response.json)
- [ ] 빈 태그 시 폴백 처리 테스트
- [ ] UseCase unit test

**완료 기준**: 이미지 입력 → 프리셋 선택 → 자막 문자열 반환 동작. 에러 시 재시도 가능.

---

## 1-2. Watermark 모듈 (텍스트 합성)
> 의존: 1-1 (자막 문자열 필요)

### Domain
- [ ] `title_style.dart`: 폰트 크기/색상/위치 설정 엔티티
- [ ] `watermark_repository.dart`: abstract class
- [ ] `composite_title.dart`: UseCase
- [ ] `apply_watermark.dart`: UseCase

### Data
- [ ] `watermark_repository_impl.dart`: Canvas API로 이미지 위 텍스트 합성
  - 옐로우 텍스트 + 블랙 아웃라인 Stroke 렌더링
  - 자막 길이에 따른 자동 폰트 크기 조절
  - 워터마크 이미지 우측 하단 삽입
- [ ] `mock_watermark_repository.dart`

### Assets
- [ ] 애니 스타일 폰트 파일 (assets/fonts/)
- [ ] 워터마크 이미지 (assets/images/watermarks/)

### 테스트
- [ ] 긴 텍스트 / 짧은 텍스트 레이아웃 테스트
- [ ] 다국어 폰트 렌더링 테스트

**완료 기준**: 이미지 + 자막 → 애니 폰트로 합성된 결과 이미지 파일 생성.

---

## 1-3. 메인 화면 UI
> 의존: 1-1, 1-2

- [ ] `home_page.dart`: 메인 화면
  - 사진 선택 버튼 (카메라/갤러리)
  - 프리셋 선택 카드 (하단 가로 스크롤)
  - "생성하기" 버튼
- [ ] `result_page.dart`: 결과 표시 화면
  - 합성된 이미지 전체 표시
  - 저장/공유 버튼
  - "다시 생성" 버튼
- [ ] `image_picker` 연동: 카메라/갤러리 선택
- [ ] 로딩 상태 UI (생성 중 인디케이터)
- [ ] 에러 상태 UI (재시도 버튼)

**완료 기준**: 전체 플로우 사진→프리셋→생성→결과표시 동작.

---

## 1-4. Gallery 모듈
> 의존: 1-3 (결과 이미지 필요)

- [ ] `gallery_item.dart`: 엔티티
- [ ] `gallery_repository.dart`: abstract + Hive 구현
- [ ] `gallery_page.dart`: 그리드 뷰 히스토리 목록
- [ ] `gallery_item_card.dart`: 썸네일 카드
- [ ] 저장/조회/삭제 기능
- [ ] 갤러리에서 항목 탭 → 결과 재확인

**완료 기준**: 생성 결과가 자동 저장되고 갤러리에서 조회/삭제 가능.

---

## 1-5. ShareKit 모듈
> 의존: 1-3 (결과 이미지 필요)

- [ ] `share_service.dart`: abstract class
- [ ] `share_service_impl.dart`: share_plus 패키지 활용
- [ ] `share_bottom_sheet.dart`: 공유 대상 선택 UI
- [ ] 디바이스 저장 (카메라롤 내보내기)
- [ ] 기본 공유 (시스템 공유 시트)

**완료 기준**: 결과 이미지를 디바이스 저장 + 타앱 공유 가능.

---

## 1-6. Onboarding 모듈
> 의존: 1-3 (체험용 플로우 필요)

- [ ] `onboarding_service.dart`: 첫 실행 여부 확인 (SharedPreferences)
- [ ] `welcome_page.dart`: 3장 소개 PageView
- [ ] `permission_page.dart`: 카메라/갤러리 권한 요청
- [ ] 샘플 이미지 내장 (assets/images/onboarding/)
- [ ] 온보딩 완료 → 메인 화면 전환

**완료 기준**: 첫 실행 시 튜토리얼 → 권한 요청 → 메인. 재실행 시 스킵.

---

## 1-7. Analytics 모듈
> 의존: Phase 0 (Firebase 설정)

- [ ] `analytics_tracker.dart`: abstract class
- [ ] `firebase_analytics_tracker.dart`: Real 구현
- [ ] `mock_analytics_tracker.dart`: 콘솔 로그
- [ ] 이벤트 삽입: photo_selected, preset_selected, title_generated, image_saved, image_shared

**완료 기준**: 주요 사용자 행동이 Firebase에 기록됨.

---

## Phase 1 최종 검증
- [ ] 전체 플로우 테스트: 사진 → 프리셋 → 자막 생성 → 결과 표시 → 저장 → 공유
- [ ] 온보딩 → 메인 진입 플로우
- [ ] 에러 케이스: 네트워크 끊김, AI 빈 응답, 대용량 이미지
- [ ] 갤러리 CRUD 동작
- [ ] `flutter test` 전체 통과
