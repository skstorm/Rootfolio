# Anime Title Academy - 전체 구현 계획서

---

## 1. 기술 스택

| 영역 | 선택 | 이유 |
|------|------|------|
| 프레임워크 | Flutter 3.x | 크로스 플랫폼, 커스텀 UI(스크래치) 구현에 강점 |
| 상태관리 | Riverpod + StateNotifier | Provider 대비 테스트 용이, 모듈 간 의존성 명확 |
| DI | get_it + injectable | 모듈별 구현체 교체 용이 |
| 네트워크 | Dio | 인터셉터, 재시도, 로깅 |
| 로컬 DB | Hive 또는 Isar | 갤러리 히스토리, 설정 저장 |
| 라우팅 | GoRouter | 딥링크 지원, 선언적 라우팅 |
| AI (Vision+LLM) | Gemini API (1차) | 멀티모달 지원, 비용 효율 |
| 이미지 변환 | Stable Diffusion API (Phase 3) | 애니 스타일 변환 품질 |
| 광고 | Google AdMob | Flutter 공식 지원, 전면/리워드 광고 |
| 결제 | RevenueCat | iOS/Android 통합 결제, 영수증 검증 |
| 분석 | Firebase Analytics | 무료, Flutter 연동 용이 |

---

## 2. 아키텍처 개요

### 2.1 Clean Architecture 3레이어

```
Presentation (UI/Provider) → Domain (UseCase/Entity/Interface) → Data (Repository/Datasource)
```

- **Domain**: 순수 Dart, 외부 의존성 없음. 인터페이스(abstract class) 정의
- **Data**: API 호출, 로컬 저장소 등 구현체
- **Presentation**: 위젯, Provider, 화면

### 2.2 10대 모듈 구성

```
[Core Modules - 4개]
  ImageGen | TitleAcademy | ScratchUX | Watermark

[Business Modules - 3개]
  AdManager | Billing | Analytics

[UX Modules - 3개]
  ShareKit | Gallery | Onboarding
```

### 2.3 모듈 간 의존성 원칙

- 순환 의존 금지
- 모듈 간 통신은 domain 레이어 인터페이스만 경유
- Billing이 유료 기능의 게이트키퍼 역할
- Analytics는 관찰자 패턴 (fire-and-forget, 장애 시 앱 기능에 영향 없음)

---

## 3. 프로젝트 폴더 구조

```
lib/
├── main.dart
├── app.dart
├── di/
│   ├── injection_container.dart
│   └── modules/                    # 모듈별 DI 설정
├── core/
│   ├── error/                      # Failure, Exception 정의
│   ├── network/                    # Dio 래퍼, 네트워크 상태
│   ├── theme/                      # 색상, 타이포그래피
│   ├── routes/                     # GoRouter 설정
│   └── constants/
├── features/
│   ├── image_gen/
│   │   ├── domain/                 # ImageEngine 인터페이스
│   │   ├── data/                   # Mock/Real 구현체
│   │   └── presentation/
│   ├── title_academy/
│   ├── scratch_ux/
│   ├── watermark/
│   ├── ad_manager/
│   ├── billing/
│   ├── share_kit/
│   ├── gallery/
│   ├── analytics/
│   └── onboarding/
├── shared/
│   ├── widgets/
│   └── providers/
├── test/
│   ├── features/                   # 모듈별 테스트
│   ├── fixtures/                   # 테스트 데이터
│   └── mocks/
└── integration_test/
```

---

## 4. Phase별 구현 계획

### Phase 0: 프로젝트 기반 (1주)

| 작업 | 상세 |
|------|------|
| Flutter 프로젝트 생성 | 폴더 구조, 패키지 설정 |
| DI 컨테이너 구성 | get_it 설정, 모듈별 Mock 주입 |
| Core 레이어 구축 | 에러 타입, 네트워크 클라이언트, 테마 |
| 라우팅 설정 | GoRouter, 화면 전환 |
| CI/CD 기본 설정 | 린트, 테스트 자동화 |

**완료 조건**: 빈 앱이 빌드/실행되고, 모든 모듈의 Mock이 주입된 상태

### Phase 1: MVP - 코어 엔진 (3-4주)

| 모듈 | 구현 내용 | 구현체 |
|------|----------|--------|
| TitleAcademy | Vision API + LLM 자막 생성 | Real (Gemini) |
| Watermark | 이미지 위에 자막 텍스트 합성 + 워터마크 | Real |
| ImageGen | 원본 이미지 그대로 반환 | **Mock** |
| ScratchUX | 결과를 즉시 표시 (스크래치 없이) | **Mock** |
| AdManager | 광고 없이 즉시 콜백 | **Mock** |
| Billing | 모든 기능 무료 상태 | **Mock** |
| Gallery | 로컬 저장/조회 | Real (기본) |
| ShareKit | 이미지 저장 + 기본 공유 | Real (기본) |
| Analytics | 기본 이벤트 수집 | Real (Firebase) |
| Onboarding | 3단계 튜토리얼 | Real |

**완료 조건**:
- [ ] 사진 선택 → 프리셋 선택 → 자막 생성 → 결과 표시 플로우 동작
- [ ] 생성된 자막이 이미지 위에 애니 폰트로 렌더링됨
- [ ] 결과물 디바이스 저장 가능
- [ ] 기본 공유 기능 동작
- [ ] 에러 발생 시 사용자에게 안내 표시

### Phase 2: 스크래치 UX (2주)

| 모듈 | 변경 내용 |
|------|----------|
| ScratchUX | Mock → Real: 터치 스크래치, 퍼센트 계산, 파티클 폭발 |

**완료 조건**:
- [ ] 손가락 문지르기로 가림막 벗겨짐
- [ ] 40% 이상 긁으면 자동 공개 + 폭발 애니메이션
- [ ] 60fps 유지 (저사양 기기 포함)
- [ ] 스크래치 도중 앱 종료 후 재진입 시 정상 처리

### Phase 3: AI 이미지 변환 (3주)

| 모듈 | 변경 내용 |
|------|----------|
| ImageGen | Mock → Real: Stable Diffusion API 연동 |

**완료 조건**:
- [ ] 원본 사진이 애니메이션 스타일로 변환됨
- [ ] 변환 시간 30초 이내
- [ ] 최소 해상도 512x512 이상
- [ ] 부적절한 이미지 모더레이션 필터 동작

### Phase 4: 수익화 (2-3주)

| 모듈 | 변경 내용 |
|------|----------|
| AdManager | Mock → Real: AdMob 전면/리워드 광고 |
| Billing | Mock → Real: RevenueCat 인앱 결제, 워터마크 제거, 커스텀 슬롯 |

**완료 조건**:
- [ ] 이미지 생성 대기 중 전면 광고 표시
- [ ] 리워드 광고 시청 → 보상 즉시 지급
- [ ] 인앱 결제로 커스텀 슬롯 구매 가능
- [ ] 워터마크 제거 구매 동작
- [ ] 결제 복원(Restore Purchase) 동작
- [ ] 영수증 서버 사이드 검증

---

## 5. 데이터 파이프라인 (최종 완성 시)

```
[사진 선택]
    │
    ▼
[Billing 확인] ─── 커스텀 필터/프롬프트 권한 체크
    │
    ├──▶ [AdManager] ─── 전면 광고 표시 (비동기로 아래 작업 병행)
    │
    ├──▶ [ImageGen] ─── 이미지 필터 변환
    │
    └──▶ [TitleAcademy] ─── Vision 분석 → LLM 자막 생성
              │
              ▼
         [Watermark] ─── 자막 텍스트 + 이미지 합성 + 워터마크(Billing 확인)
              │
              ▼
         [ScratchUX] ─── 스크래치 공개 연출
              │
              ▼
         [Gallery 저장] + [ShareKit 공유]
              │
              └──▶ [Analytics] ─── 전 구간 이벤트 수집
```

---

## 6. 테스트 전략

| 레벨 | 범위 | 도구 |
|------|------|------|
| Unit Test | UseCase, Repository, Provider | flutter_test, mockito |
| Widget Test | 개별 위젯 렌더링/인터랙션 | flutter_test |
| Integration Test | 전체 플로우 (사진→자막→스크래치→공유) | integration_test |
| Golden Test | 자막 렌더링 결과 스냅샷 비교 | golden_toolkit |

### Mock 전략
- 모든 모듈은 Mock 구현체를 함께 제공
- Phase 전환 시 DI 컨테이너에서 구현체만 교체
- 테스트 시 항상 Mock 사용으로 외부 의존성 제거

---

## 7. 에러 핸들링 전략

```dart
// 모든 모듈 공통 Result 타입
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}

// 실패 유형 분류
abstract class AppFailure {
  final String message;
  const AppFailure(this.message);
}
class NetworkFailure extends AppFailure { ... }
class ServerFailure extends AppFailure { ... }
class AIGenerationFailure extends AppFailure { ... }
class StorageFailure extends AppFailure { ... }
```

---

## 8. 환경 분기

| 환경 | AI API | 광고 | 결제 |
|------|--------|------|------|
| dev | Mock (로컬 JSON) | Mock | Mock |
| staging | Real (Gemini) | Test Ad | Sandbox |
| prod | Real (Gemini) | Real Ad | Real |
