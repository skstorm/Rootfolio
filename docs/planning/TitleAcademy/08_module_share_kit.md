# 모듈 상세 계획서: ShareKit (공유)

## 개요
SNS 공유, 이미지 내보내기. 바이럴 성장의 핵심.

---

## 인터페이스

```dart
abstract class ShareService {
  Future<Result<void>> shareToSocial({
    required File image,
    required String caption,
    ShareTarget? target, // kakao, instagram, twitter, general
  });
  Future<Result<File>> saveToDevice(File image);
}

enum ShareTarget { kakao, instagram, twitter, general }
```

## 구현

```
features/share_kit/
├── domain/
│   └── share_service.dart
├── data/
│   ├── share_service_impl.dart      # share_plus 패키지 활용
│   └── platform/
│       ├── kakao_share.dart         # 카카오톡 공유 API
│       └── instagram_share.dart     # 인스타 스토리 공유
└── presentation/
    └── widgets/
        └── share_bottom_sheet.dart   # 공유 대상 선택 시트
```

## 공유 시 자동 포함
- 앱 다운로드 링크
- 워터마크 (무료 사용자)
- 앱 로고 (선택)

## Phase: Phase 1부터 기본 공유 (general), 이후 플랫폼별 확장
