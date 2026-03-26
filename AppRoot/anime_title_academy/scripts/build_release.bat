@echo off
echo =======================================================
echo [Anime Title Academy] 상용 릴리스 빌드 (Release)
echo =======================================================
echo.
echo - 대상: Windows 실행 파일 (.exe)
echo - 설정: 프로덕션(상용) 모드
echo.
echo 주의: 이 파일은 예시 구조입니다! 실제 배포 시에는 'YOUR_REAL_API_KEY' 부분을 교체하거나, 
echo 이 파일을 CI(Git Action 등)에서만 사용해야 합니다. (로컬 커밋 금지)
echo.

flutter build windows --release --dart-define=ENVIRONMENT=prod --dart-define=GEMINI_API_KEY=YOUR_REAL_API_KEY

echo.
echo 빌드가 완료되었습니다! 결과 폴더: build\windows\x64\runner\Release
pause
