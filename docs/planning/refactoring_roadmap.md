# Refactoring Roadmap for Advanced AI

이 문서는 2일 뒤 고급 AI 모델을 통해 수행할 리팩터링 항목과 가이드를 정리한 체크리스트입니다.

## 1. 핵심 리팩터링 항목 (USER Request)
- [ ] **보안 (Security)**:
  - `.env` 및 `.gitignore` 설정 재검토.
  - 소스 코드 내 하드코딩된 모든 민감 정보(API 키, 서버 주소 등) 전수 조사 및 제거.
  - CI/CD 파이프라인 도입 시 Secrets 관리 자동화 검토.
- [ ] **이미지 해석 고속화 (Performance)**:
  - 현재의 '투스텝(Two-step)' 파이프라인을 최적화하여 레이턴시 최소화.
  - Gemini Flash 모델의 `system_instruction` 기능을 활용한 컨텍스트 압축.
  - 이미지 리사이징/압축 후 전송 로직 강화 (페이로드 축소).
- [ ] **코드 가독성 향상 (Readability)**:
  - Clean Architecture 레이어링(Domain-Data-Presentation)의 엄격한 준수.
  - 함수 및 변수 명명법 통일 (Dart 스타일 가이드 적용).
- [ ] **불필요한 코드 정리 (Dead Code)**:
  - `AnalyzeImageUseCase` 등 현재 사용되지 않는 Legacy UseCase 및 파일 정리.
  - 미사용 import 제거 및 `pubspec.yaml` 종속성 최적화.
- [ ] **중복 코드 제거 (DRY)**:
  - `TitleRepositoryImpl` 내의 유사 로직 공통화.
  - 여러 DataSource에서 중복되는 Gemini 클라이언트 초기화 로직 통합.

## 2. 추가 제안 항목 (By Antigravity)
- [ ] **의존성 주입(DI) 시스템 통합**:
  - 현재 `manual_setup.dart`(수동)와 `injectable`(자동)이 혼재되어 있습니다. `build_runner` 안정성을 확보하여 하나의 방식으로 통일이 필요합니다.
- [ ] **상태 관리(Riverpod) 아키텍처 표준화**:
  - `autoDispose` 사용 시 발생하는 상태 유지 문제를 해결하고, 에러 핸들링(`AsyncValue` 등) 패턴을 전역적으로 통일해야 합니다.
- [ ] **에러 핸들링 및 복구 전략 (Resilience)**:
  - `Result` 타입을 일관되게 처리하는 패턴(Functional handling) 도입.
  - API 호출 실패 시 재시도(Retry) 로직 및 사용자 친화적 에러 메시지 표준화.
- [ ] **테스트 코드 도입**:
  - 복잡한 로직이 포함된 `PromptTemplateService`에 대한 유닛 테스트 작성.
  - Repository 계층의 Mock 테스트 강화.
- [ ] **로깅 시스템 고도화**:
  - `print` 문을 제거하고, `logger` 패키지를 사용하여 로그 레벨별(Info, Debug, Error) 관리 및 배포 시 로그 노출 제어.

## 3. 리팩터링 순서 가이드
1. **Security First**: 보안 취약점 제거 및 환경 변수 설정 표준화.
2. **Architecture Core**: DI 통합 및 상태 관리 구조 재정립.
3. **Business Logic**: 파이프라인 고속화 및 중복 로직 제거.
4. **Cleanup & Polishing**: 가독성 향상 및 죽은 코드 정리.
