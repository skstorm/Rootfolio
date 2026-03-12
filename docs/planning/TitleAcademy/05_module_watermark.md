# 모듈 상세 계획서: Watermark (워터마크/텍스트 렌더링)

## 개요
이미지 위에 자막 텍스트를 합성하고 워터마크를 삽입하는 모듈. Billing과 연동하여 워터마크 제거.

---

## 인터페이스

```dart
abstract class WatermarkEngine {
  /// 이미지 위에 자막 텍스트를 애니 폰트 스타일로 합성
  Future<Result<File>> compositeTitle({
    required File image,
    required String titleText,
    required TitleStyle style,
  });

  /// 워터마크 삽입 (Billing 상태에 따라 조건부)
  Future<Result<File>> applyWatermark({
    required File image,
    required bool isPremium,
  });
}

class TitleStyle {
  final double fontSize;
  final Color fontColor;
  final Color strokeColor;
  final double strokeWidth;
  final Alignment position;
  final String fontFamily;
}
```

## 내부 구조

```
features/watermark/
├── domain/
│   ├── entities/
│   │   └── title_style.dart
│   ├── repositories/
│   │   └── watermark_repository.dart
│   └── usecases/
│       ├── composite_title.dart
│       └── apply_watermark.dart
├── data/
│   ├── watermark_repository_impl.dart   # Canvas API로 합성
│   └── mock_watermark_repository.dart
└── presentation/
    └── widgets/
        └── title_style_editor.dart       # 폰트 크기/위치 조정 UI
```

## 텍스트 렌더링 스타일

- **기본**: 밝은 옐로우 + 굵은 블랙 아웃라인 (애니/예능 자막 감성)
- Canvas API(dart:ui)로 이미지 위에 직접 드로잉
- 자막 길이에 따른 자동 폰트 크기 조절
- 다국어 폰트 지원 (한/일/영)

## Phase 진화

| Phase | 상태 |
|-------|------|
| Phase 1 | Real (텍스트 합성 + 워터마크 강제) |
| Phase 4 | Billing 연동 (Pro 사용자 워터마크 제거) |

## 테스트 포인트

- 다양한 텍스트 길이에서 레이아웃 깨짐 없음
- 워터마크 위치/투명도 정확성
- isPremium=true 시 워터마크 미삽입
