# 모듈 상세 계획서: TitleAcademy (자막 생성)

## 개요
이미지를 분석하여 유머러스한 애니메이션 스타일 자막을 생성하는 핵심 모듈.

---

## 인터페이스

```dart
abstract class TitleEngine {
  Future<Result<List<String>>> analyzeVariables(File image);
  Future<Result<String>> generateTitle(List<String> tags, String presetPrompt);
}
```

## 내부 구조

```
features/title_academy/
├── domain/
│   ├── entities/
│   │   ├── image_analysis.dart      # 분석 결과 엔티티
│   │   └── title_result.dart        # 생성된 자막 엔티티
│   ├── repositories/
│   │   └── title_repository.dart    # abstract
│   └── usecases/
│       ├── analyze_image.dart
│       └── generate_title.dart
├── data/
│   ├── datasources/
│   │   ├── gemini_vision_datasource.dart   # Vision API 호출
│   │   └── gemini_llm_datasource.dart      # LLM 자막 생성
│   ├── models/
│   │   ├── vision_response_model.dart
│   │   └── llm_response_model.dart
│   └── repositories/
│       ├── title_repository_impl.dart
│       └── mock_title_repository.dart
└── presentation/
    ├── providers/
    │   └── title_provider.dart
    └── widgets/
        └── preset_selector.dart     # 프리셋 선택 카드 UI
```

## 파이프라인

```
원본 이미지 → [Vision API] → 태그 리스트 (사물, 상황, 감정)
    → [프리셋 프롬프트 + 태그] → [LLM] → 유머 자막 문자열
```

## 프리셋 프롬프트 설계

| 프리셋 | 시스템 프롬프트 핵심 |
|--------|---------------------|
| 다큐멘터리 | "내셔널 지오그래픽 나레이션 톤으로, 과장된 생존 서사" |
| 인터넷 밈 | "한국 인터넷 드립 톤으로, ㅋㅋ 포함, MZ세대 유머" |
| 로맨스/순정 | "순정만화 독백 톤으로, 과장된 감정 표현" |
| 커스텀 | 사용자 입력 컨셉을 시스템 프롬프트에 삽입 |

## 외부 의존성

| 패키지/서비스 | 용도 |
|--------------|------|
| google_generative_ai | Gemini API (Vision + LLM) |
| dio | HTTP 클라이언트 (프록시 서버 경유 시) |

## Mock 구현

```dart
class MockTitleRepository implements TitleRepository {
  Future<Result<String>> generateTitle(...) async {
    await Future.delayed(Duration(seconds: 1)); // 딜레이 시뮬레이션
    final samples = ['생존을 위한 극한의 사투...', '아 ㅋㅋ 퇴근 마려운 폼...'];
    return Success(samples[Random().nextInt(samples.length)]);
  }
}
```

## Phase 진화

| Phase | 상태 |
|-------|------|
| Phase 1 | Real 구현 (Gemini Vision + LLM) |
| Phase 3 | 변환된 AI 이미지도 분석 대상에 포함 |

## 테스트 포인트

- Vision API 응답 파싱 정확성
- 프리셋별 프롬프트 조합 검증
- 빈 태그 / 빈 응답 시 폴백 처리
- 네트워크 타임아웃 시 재시도
- 부적절 콘텐츠 필터링
