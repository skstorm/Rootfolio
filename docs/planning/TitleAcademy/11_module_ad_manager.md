# 모듈 상세 계획서: AdManager (광고) - 수익화

## 개요
전면 광고 및 리워드 광고를 관리. UI 코드와 완전 분리. **앱 완성도를 높인 후 마지막에 구현.**

---

## 인터페이스

```dart
abstract class AdManager {
  Future<void> initialize();
  Future<bool> isAdReady(AdType type);
  void showInterstitialAd({required VoidCallback onClosed});
  void showRewardedAd({required VoidCallback onEarned, required VoidCallback onFailed});
  void dispose();
}

enum AdType { interstitial, rewarded }
```

## 내부 구조

```
features/ad_manager/
├── domain/
│   └── ad_manager.dart              # abstract class
├── data/
│   ├── admob_ad_manager.dart        # Real 구현 (Google AdMob)
│   └── mock_ad_manager.dart         # 즉시 콜백 반환
└── presentation/
    └── widgets/
        └── ad_loading_overlay.dart   # 광고 로딩 중 UI
```

## Mock 구현 (앱 완성 전까지 사용)

```dart
class MockAdManager implements AdManager {
  void showInterstitialAd({required VoidCallback onClosed}) {
    onClosed(); // 광고 없이 즉시 진행
  }
  void showRewardedAd({required VoidCallback onEarned, ...}) {
    onEarned(); // 즉시 보상 지급
  }
}
```

## 외부 의존성
- google_mobile_ads (AdMob Flutter 플러그인)

## 광고 정책
- 전면 광고: 이미지 생성 대기 시간에 1회 표시
- 리워드 광고: 커스텀 슬롯 확장 시 3회 연속 시청
- 광고 로딩 실패 시: 스킵 후 정상 진행 (사용자 차단 금지)
- Billing에서 광고 제거 구매 확인 → 광고 미표시

## 테스트 포인트
- 광고 로딩 실패 시 앱 정상 진행
- 리워드 미완료 시 보상 미지급
- Billing 연동: Pro 사용자에게 광고 미표시
