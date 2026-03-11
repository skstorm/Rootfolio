# Anime Title Academy - 상세 구현 기획서 (Architecture Plan)

본 문서는 엔지니어(구현 전문가)의 관점에서, 확장이 용이하고 모듈 간의 결합도가 낮은(Decoupled) 시스템을 구축하기 위한 플러터(Flutter) 아키텍처 설계도입니다.

---

## 🏗️ 1. 아키텍처 핵심 철학
사용자님의 요구사항인 **"이미지 필터, 제목 생성, 광고, 스크래치 기능 4가지가 확장/변경이 쉽도록 모듈화"**하는 것이 본 프로젝트 아키텍처의 알파이자 오메가입니다. 

의존성 주입(DI) 또는 Provider 패턴을 사용하여, 각 모듈의 '구현체'를 언제든 갈아끼울 수 있도록 **인터페이스(Abstract Class)** 기반으로 설계합니다.

---

## 🧩 2. 핵심 4대 모듈 인터페이스 설계

### ① ImageGen Module (이미지 필터 기능)
원본 이미지를 받아 특정 스타일(애니메이션, 픽셀아트 등)로 변환한 뒤 반환합니다. Phase 3 전까지는 원본을 그대로 반환하는 Mock(더미) 구현체를 사용합니다.

```dart
/// lib/features/image_gen/domain/image_engine.dart
abstract class ImageEngine {
  /// source: 원본 이미지
  /// stylePrompt: 필터 스타일 (예: 'anime', 'pixel art')
  Future<File> transformImage({required File source, required String stylePrompt});
}
```

### ② TitleAcademy Module (이미지 해석 및 제목 생성 기능)
두 가지 파이프라인(Vision 분석 -> LLM 텍스트 생성)을 캡슐화합니다. 차후 Gemini에서 GPT-4V, 또는 클로드로 LLM을 변경하더라도 이 인터페이스만 맞추면 됩니다.

```dart
/// lib/features/title_gen/domain/title_engine.dart
abstract class TitleEngine {
  /// 이미지를 분석하여 텍스트 태그 목록 추출
  Future<List<String>> analyzeVariables(File image);
  
  /// 추출된 태그와 사용자 프리셋(다큐, 밈 등)을 바탕으로 자막 문장 생성
  Future<String> generateTitle(List<String> tags, String presetPrompt);
}
```

### ③ AdManager Module (수익화 및 광고 기능)
플러터 UI 코드 내부(`Widget build()`)에 광고 로직이 섞이지 않도록 완벽히 분리합니다. 

```dart
/// lib/features/ads/domain/ad_manager.dart
abstract class AdManager {
  Future<void> initialize();
  
  /// 로딩 대기 시간(이미지 생성 등)에 호출할 전면 광고
  void showInterstitialAd({required VoidCallback onClosed});
  
  /// 커스텀 슬롯 확장 등을 위한 보상형 광고 (콜백 기반 제어)
  void showRewardedAd({required VoidCallback onEarned, required VoidCallback onFailed});
}
```

### ④ Scratch UX Module (상호작용 연출 기능)
위의 ①, ② 모듈을 통해 완성된 **결과 이미지(Back)**와 **가림막 이미지(Front)**를 받아 스크래치 상호작용을 담당하는 순수 UI 위젯 모듈입니다. 다른 비즈니스 로직(AI 호출 등)을 절대 포함하지 않습니다.

```dart
/// lib/features/scratch_ux/presentation/scratch_view.dart
class ScratchWrapperView extends StatelessWidget {
  final Widget obscuredCover;  // 긁어낼 앞면 (회색막, 애니 등)
  final Widget resultPayload;  // 긁었을 때 드러날 뒷면 (필터 + 자막 조합)
  final double thresholdRatio; // 벗겨짐 완료 처리 임계값 (예: 0.4 = 40%)
  final VoidCallback onClear;  // 완전히 벗겨졌을 때 폭발 애니메이션 등을 트리거할 콜백

  const ScratchWrapperView({
    Key? key,
    required this.obscuredCover,
    required this.resultPayload,
    this.thresholdRatio = 0.4,
    required this.onClear,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 내부적으로 scratcher 패키지 등을 감싸서 구현
  }
}
```

---

## 🔄 3. 데이터 파이프라인 흐름 (Phase 연계 로직)

위의 4개 모듈을 엮어내는 `AppController` (또는 ViewModel/Provider)의 로직 개요입니다. 이 흐름을 따라 코드가 작성될 것입니다.

1. **User Action**: 사용자 이미지 선택 및 '다큐멘터리' 프리셋 터치
2. **Phase 4 - AdManager 개입**: `AdManager.showInterstitialAd(...)` (전면 광고 띄우면서 뒤쪽에서는 비동기 통신 시작)
3. **Phase 3 - ImageEngine 호출**: `transformImage(image, 'anime')` → 변환된 AI 이미지 획득
4. **Phase 1 - TitleEngine 호출**: `analyzeVariables(image)` → `generateTitle(tags, preset)` → 자막 획득
5. **Phase 2 - Scratch UX 전환**: 광고가 끝나고 닫히면, 3번(필터 이미지)과 4번(자막)을 텍스트 렌더링(Stack)으로 묶어 `ScratchWrapperView`의 `resultPayload`로 전달.
6. **User Output**: 스크래치 완료 후 저장 액션 (워터마크 삽입 처리).

---

## 🛠 4. 모듈 확장의 이점 (결론)
이렇게 4개의 거대한 기둥을 분리해두면:
- **Phase 1 작업 시**: ImageEngine은 무조건 원본 사진을 뱉고, AdManager는 기다림 없이 즉시 콜백을 실행하도록 Mock 인스턴스만 주입합니다.
- **Phase 3/4 작업 시**: 기존 로직과 UI(ScratchUX)를 0.1%도 수정하지 않고, 의존성을 `RealAdManager`나 `StableDiffusionEngine`으로 갈아끼우기만 하면 상용화 버전에 진입할 수 있습니다.
