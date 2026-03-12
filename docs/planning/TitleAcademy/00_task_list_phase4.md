# Task List - Phase 4: 수익화 (마지막)

> 의존: Phase 3 완료, 앱 완성도 확보 후 진행
> 목표: 광고 + 인앱 결제 탑재

---

## 4-1. AdManager 모듈 Real 구현

### 설정
- [ ] AdMob 계정 생성 + 앱 등록
- [ ] 광고 단위 ID 발급 (전면, 리워드)
- [ ] `google_mobile_ads` 패키지 추가
- [ ] Android: AndroidManifest.xml AdMob App ID 추가
- [ ] iOS: Info.plist GADApplicationIdentifier 추가

### Data
- [ ] `admob_ad_manager.dart`: Real 구현
  - initialize(): 광고 SDK 초기화
  - showInterstitialAd(): 이미지 생성 대기 중 전면 광고
  - showRewardedAd(): 커스텀 슬롯 확장용 리워드 광고
  - 광고 로딩 실패 시 스킵 후 정상 진행

### DI 교체
- [ ] injection_container.dart: MockAdManager → AdmobAdManager로 교체

### 통합
- [ ] 이미지 생성 시작 시 전면 광고 표시
- [ ] 커스텀 슬롯 확장 시 리워드 광고 3회 연속 시청 요구
- [ ] Billing 연동: Pro 사용자에게 광고 미표시

### 테스트
- [ ] 테스트 광고 ID로 전면/리워드 광고 표시 확인
- [ ] 광고 로딩 실패 시 앱 정상 진행 확인
- [ ] 리워드 미완료 시 보상 미지급 확인

---

## 4-2. Billing 모듈 Real 구현

### 설정
- [ ] RevenueCat 계정 생성 + 앱 등록
- [ ] App Store / Play Store 인앱 상품 등록
  - 워터마크 제거 (비소모품)
  - 광고 제거 (비소모품)
  - 커스텀 슬롯 추가 (소모품)
- [ ] `purchases_flutter` 패키지 추가

### Data
- [ ] `revenue_cat_billing_service.dart`: Real 구현
  - initialize(): RevenueCat SDK 초기화
  - purchase(): 인앱 결제 실행
  - restorePurchases(): 구매 복원
  - entitlementStream: 권한 상태 스트림
  - hasEntitlement(): 권한 확인

### DI 교체
- [ ] injection_container.dart: MockBillingService → RevenueCatBillingService로 교체

### 통합
- [ ] Watermark 모듈 연동: isPremium 확인 → 워터마크 제거
- [ ] AdManager 연동: removeAds 권한 → 광고 미표시
- [ ] 커스텀 프리셋 UI: 잠금 아이콘 + 결제/광고 선택 다이얼로그
- [ ] 설정 화면에 "구매 복원" 버튼 추가

### 테스트
- [ ] Sandbox 환경에서 결제 성공/실패/취소 테스트
- [ ] 구매 복원 동작 확인
- [ ] 네트워크 끊김 시 캐시된 권한으로 기능 유지

---

## Phase 4 완료 기준
- [ ] 전면 광고 정상 표시
- [ ] 리워드 광고 시청 → 보상 지급
- [ ] 인앱 결제로 워터마크 제거/광고 제거 동작
- [ ] 구매 복원 동작
- [ ] Pro 사용자: 워터마크 없음 + 광고 없음
- [ ] 전체 플로우 최종 검증

---

## 출시 전 최종 체크리스트
- [ ] 개인정보 처리방침 URL 준비
- [ ] 앱스토어 스크린샷/설명 준비
- [ ] 프로덕션 광고 ID 적용 (테스트 ID 제거)
- [ ] 프로덕션 API 키 환경변수 적용
- [ ] `flutter build appbundle` / `flutter build ipa` 성공
- [ ] 크래시 리포팅 설정 (Firebase Crashlytics)
- [ ] 앱 아이콘/스플래시 스크린 적용
