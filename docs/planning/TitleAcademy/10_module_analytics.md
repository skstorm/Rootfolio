# 모듈 상세 계획서: Analytics (분석/추적)

## 개요
사용자 행동 이벤트를 수집하는 관찰자 모듈. UI 없음. 모든 모듈에서 의존하되, 장애 시 앱 기능에 영향 없음 (fire-and-forget).

---

## 인터페이스

```dart
abstract class AnalyticsTracker {
  Future<void> initialize();
  void trackEvent(String name, {Map<String, dynamic>? params});
  void trackScreen(String screenName);
  void setUserProperty(String key, String value);
}
```

## 구현

| 구현체 | 설명 |
|--------|------|
| FirebaseAnalyticsTracker | Firebase Analytics 연동 |
| MockAnalyticsTracker | 콘솔 로그 출력 (개발용) |

## 추적 이벤트 목록

| 이벤트 | 파라미터 | 시점 |
|--------|---------|------|
| photo_selected | source(camera/gallery) | 사진 선택 |
| preset_selected | preset_type | 프리셋 터치 |
| title_generated | preset_type, latency_ms | 자막 생성 완료 |
| scratch_started | - | 첫 터치 |
| scratch_completed | duration_ms | 공개 완료 |
| image_saved | - | 디바이스 저장 |
| image_shared | target(kakao/insta/etc) | 공유 |
| ad_shown | ad_type(interstitial/rewarded) | 광고 표시 |
| purchase_completed | product_id | 결제 완료 |

## Phase: Phase 1부터 기본 이벤트 수집

## 설계 원칙
- 모든 호출은 try-catch 감싸서 실패해도 무시
- 비즈니스 로직에 영향 없는 순수 사이드이펙트
- GDPR 대응: 사용자 동의 전에는 수집 비활성화
