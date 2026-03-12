# 모듈 상세 계획서: Onboarding (온보딩)

## 개요
첫 실행 시 앱 사용법 안내, 권한 요청, 약관 동의를 처리하는 모듈.

---

## 인터페이스

```dart
abstract class OnboardingService {
  Future<bool> isFirstLaunch();
  Future<void> markOnboardingComplete();
  Future<OnboardingStep> getCurrentStep();
}

enum OnboardingStep {
  welcome,       // 앱 소개
  tutorial,      // 사진→프리셋→스크래치 체험
  permissions,   // 카메라/갤러리 권한
  privacyConsent,// 개인정보 동의
  complete,
}
```

## 내부 구조

```
features/onboarding/
├── domain/
│   └── onboarding_service.dart
├── data/
│   └── onboarding_service_impl.dart   # SharedPreferences 기반
└── presentation/
    ├── pages/
    │   ├── welcome_page.dart          # 앱 소개 (PageView)
    │   ├── tutorial_page.dart         # 샘플 이미지로 체험
    │   └── permission_page.dart       # 권한 요청
    └── widgets/
        └── onboarding_indicator.dart  # 페이지 인디케이터
```

## 온보딩 플로우

```
앱 첫 실행 → Welcome (3장 소개) → 개인정보 동의 → 권한 요청
    → 샘플 이미지로 자막 생성 체험 → 메인 화면 진입
```

## 핵심 포인트
- 샘플 이미지 내장으로 사진 권한 요청 전에 체험 가능 (진입장벽 제거)
- 개인정보 동의 화면은 앱스토어 심사 필수
- 온보딩 완료 상태를 로컬에 저장, 재설치 전까지 미표시

## Phase: Phase 1부터 구현
