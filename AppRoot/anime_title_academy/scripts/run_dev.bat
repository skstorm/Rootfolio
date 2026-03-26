@echo off
echo =======================================================
echo [Anime Title Academy] 개발 모드 (Dev) 앱 실행 중...
echo =======================================================
echo.
echo - 설정: 순수 로직/UI 개발 포커스
echo - 상태: 광고 비활성화, 할당량 우회 (무제한 테스트)
echo.

flutter run -d windows --dart-define=FORCE_QUOTA_AND_ADS=false
