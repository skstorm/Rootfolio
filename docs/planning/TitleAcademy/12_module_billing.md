# 모듈 상세 계획서: Billing (인앱 결제) - 수익화

## 개요
인앱 결제, 구독, 기능 권한(Entitlement) 관리. AdManager/Watermark의 게이트키퍼. **앱 완성도를 높인 후 마지막에 구현.**

---

## 인터페이스

```dart
abstract class BillingService {
  Future<void> initialize();
  Stream<EntitlementState> get entitlementStream;
  Future<bool> hasEntitlement(Entitlement type);
  Future<Result<void>> purchase(ProductId productId);
  Future<Result<void>> restorePurchases();
}

enum Entitlement { removeAds, removeWatermark, customSlot, extraSlots }

class EntitlementState {
  final bool isPremium;
  final int customSlotCount;
  final Set<Entitlement> active;
}
```

## 구현

| 구현체 | 설명 |
|--------|------|
| MockBillingService | 모든 권한 열림, 결제 없이 진행 |
| RevenueCatBillingService | RevenueCat SDK 연동, 영수증 서버 검증 |

## Mock 구현 (앱 완성 전까지 사용)

```dart
class MockBillingService implements BillingService {
  Future<bool> hasEntitlement(Entitlement type) async => true; // 모든 기능 열림
  Future<Result<void>> purchase(ProductId id) async => Success(null);
}
```

## 외부 의존성
- purchases_flutter (RevenueCat SDK)

## 테스트 포인트
- 결제 성공/실패/취소 각 경로
- 구매 복원(Restore Purchase) 동작
- 네트워크 끊김 시 권한 캐시
- 영수증 서버 사이드 검증
