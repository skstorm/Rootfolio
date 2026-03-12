# 모듈 상세 계획서: ScratchUX (스크래치 연출)

## 개요
결과 이미지를 복권처럼 스크래치하여 공개하는 순수 UI 모듈. 비즈니스 로직 불포함.

---

## 인터페이스

```dart
class ScratchWrapperView extends StatelessWidget {
  final Widget obscuredCover;   // 앞면 (가림막)
  final Widget resultPayload;   // 뒷면 (결과물)
  final double thresholdRatio;  // 공개 임계값 (기본 0.4)
  final VoidCallback onClear;   // 완전 공개 시 콜백
  final VoidCallback? onStart;  // 첫 터치 시 콜백
}
```

## 내부 구조

```
features/scratch_ux/
├── domain/
│   └── scratch_config.dart          # 설정값 엔티티
├── data/
│   └── scratch_state_store.dart     # 진행 상태 임시 저장
└── presentation/
    ├── painters/
    │   └── scratch_painter.dart     # CustomPainter (핵심)
    ├── providers/
    │   └── scratch_provider.dart    # 스크래치 퍼센트 상태
    ├── widgets/
    │   ├── scratch_wrapper_view.dart
    │   ├── scratch_canvas.dart      # 터치 이벤트 처리
    │   └── reveal_particle.dart     # 폭발 파티클 위젯
    └── animations/
        └── confetti_controller.dart # Lottie/Rive 애니메이션
```

## 스크래치 동작 흐름

```
1. Front(가림막) 표시: 원본 그레이스케일 or "변환 중" UI
2. 사용자 터치 시작 → onStart 콜백
3. GestureDetector로 터치 좌표 수집
4. CustomPainter가 터치 경로를 투명하게 처리 (BlendMode.clear)
5. 투명 영역 비율 실시간 계산
6. thresholdRatio(40%) 도달 → 자동 전체 공개
7. 파티클 폭발 애니메이션 재생 → onClear 콜백
```

## 외부 의존성

| 패키지 | 용도 |
|--------|------|
| scratcher (또는 자체 구현) | 스크래치 캔버스 기본 |
| lottie | 폭발/파티클 애니메이션 |

## Mock 구현 (Phase 1)

```dart
// 스크래치 없이 결과를 즉시 표시
class MockScratchView extends StatelessWidget {
  Widget build(context) => resultPayload; // 바로 결과 표시
}
```

## Phase 진화

| Phase | 상태 | 설명 |
|-------|------|------|
| Phase 1 | Mock | 결과 즉시 표시 |
| Phase 2 | Real | 스크래치 터치, 퍼센트 계산, 파티클 폭발 |

## 성능 요구사항

- 60fps 유지 (CustomPainter 최적화)
- 고해상도 이미지 위 터치 드로잉 시 메모리 관리
- RepaintBoundary로 불필요한 리빌드 방지
- **Phase 2 시작 전 기술 PoC 필수**

## 테스트 포인트

- 퍼센트 계산 정확성 (0~100%)
- 임계값 도달 시 콜백 정상 호출
- 앱 종료 후 재진입 시 상태 처리
- 다양한 화면 크기 대응
