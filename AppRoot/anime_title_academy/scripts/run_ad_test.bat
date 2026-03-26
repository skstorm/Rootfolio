@echo off
echo =======================================================
echo [Anime Title Academy] 수익화/광고 테스트 (Ad Test) 앱 실행 중...
echo =======================================================
echo.
echo - 설정: 과금 및 광고 로직 검증용
echo - 상태: 할당량 강제 적용, 모의(Fake) 보상형 광고 재생
echo.

flutter run -d windows --dart-define=FORCE_QUOTA_AND_ADS=true --dart-define=REWARDED_AD_MODE=fake
