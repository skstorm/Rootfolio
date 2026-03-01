# Rootfolio Project Memory

## 프로젝트 구조
- **루트**: `E:\Study\Rootfolio`
- **앱**: `AppRoot/ladder_game` (Flutter 웹앱)
- **배포 대상**: `WebRoot/public/apps/`
- **배포 엔진**: `packages/deploy-engine/` (TypeScript, ESM)

## Flutter 개발 환경 이슈 (중요)

### 핵심 제약
- 프로젝트: `E:` 드라이브 / Flutter SDK (puro): `C:` 드라이브
- `flutter run -d chrome` **debug 모드는 동작하지 않음** (Flutter 업스트림 버그)
- 버그 위치: `frontend_server_aot.dart.snapshot`의 `_ensureFolderPath` 함수가 Windows 크로스드라이브 경로에서 `uri.path`(잘못됨) 사용

### 올바른 실행 방법
```bash
npm run dev:ladder   # --profile 모드로 Chrome 실행
# r 키: Hot Restart / q 키: 종료
```

### npm 스크립트 규칙
- 반드시 `puro flutter`를 사용할 것 (`flutter` bash 스크립트는 동작 안 함)
- `puro flutter run -d chrome --profile` (debug 모드 X)

## 배포
```bash
npm run deploy-app ladder_game
```

## 주요 파일
- `package.json`: npm 스크립트
- `scripts/deploy-app.ts`: 배포 스크립트 (ESM, `import.meta.url` 기반)
- `packages/deploy-engine/index.ts`: 배포 엔진
- `WebRoot/public/apps-metadata.json`: 앱 메타데이터
