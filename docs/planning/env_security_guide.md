# Anime Title Academy - API 키 보안 배포 가이드라인

## 1. 현재 구조의 문제점 (개발 환경 특화)
현재 프로젝트는 개발 편의성을 위해 `flutter_dotenv` 패키지를 활용하여 `pubspec.yaml`의 `assets`에 `.env` 파일을 직접 포함시키고 있습니다.
문제는 이렇게 빌드된 앱(APK, IPA, EXE 등 클라이언트 빌드물)은 압축만 풀면 누구나 내부의 `.env` 파일을 텍스트 에디터로 열어 **Gemini API Key를 탈취할 수 있다는 점**입니다. 
(클라이언트 내에 API Key를 직접 들고 있는 앱 아키텍처의 공통적인 보안 한계입니다.)

## 2. 권장되는 릴리스(상용 배포) 전환 방식

앱 마켓(구글 플레이스토어, 앱스토어)에 정식 배포하기 전에는, 다음 두 가지 방법 중 하나를 선택해 적용해야 합니다.

### 방법 A: 다트 컴파일 타임 주입 (`--dart-define`, 권장 수준: 보통)
빌드 시점에 바이너리 코드로 컴파일되어 단순 텍스트 기반 추출을 어렵게 만듭니다. 완벽한 보안 방탄복은 아니지만, 해커가 키를 빼내려면 디컴파일 등 큰 노력이 들어가므로 1차적인 방어선이 됩니다.

1. `pubspec.yaml`의 `assets` 영역에서 `- .env` 설정을 **제거**합니다.
2. 빌드 스크립트(명령어) 수정:
   ```bash
   flutter build apk --dart-define=GEMINI_API_KEY=실제_키값
   ```
3. 앱 코드 `AppRuntimeConfig` 변경:
   ```dart
   // dotenv.env['GEMINI_API_KEY'] (런타임 로드) 대신, 아래처럼 컴파일 타임 상수를 사용.
   const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
   ```

### 방법 B: 백엔드 프록시 서버 운용 (권장 수준: 매우 높음 - 정석)
API 키를 모바일에 아예 두지 않고, 관리자만의 릴레이 백엔드를 구성하여 `모바일 앱 -> 내 서버 -> Gemini API` 방향으로 호출하는 방식입니다.

1. Cloudflare Workers, Firebase Cloud Functions, Vercel 등을 활용해 간단한 서버 리스너 작성.
2. 서버 내부 시스템 환경 변수에 `GEMINI_API_KEY` 강력 격리.
3. 앱 코드에서는 본인 백엔드 API 주소로만 요청을 보냄. (모바일 단말기에서는 Google API Key의 흔적조차 소멸됨)

## 3. 요약 및 액션 아이템
기획서 상의 **Phase 3/4**를 마치고 **정규 출시 직전**에 반드시 **방법 A** 또는 **방법 B**로 아키텍처 스위칭 계획을 수립하세요. 
만약 키 유출 시 심각한 연산 과다 과금이 발생할 수 있으므로, Google AI Studio/Google Cloud 콘솔 차원에서의 "API 결제 상한선(Billing Quota) 제한" 설정도 필수입니다.
