# Gemini API 기반 자막 생성 구현 계획 (Phase 4.1)

작성일: 2026-03-14

## 개요
현재 더미 데이터만 반환하는 `GeminiVisionDatasource` 및 `GeminiLlmDatasource` 로직을, 실제 구글 **Gemini API (`google_generative_ai` 패키지)** 를 연동하도록 개선하여 실제 이미지 분석 기반 맞춤형 자막을 생성합니다.

## 1. 환경 및 의존성 설정
*   **패키지 추가 (`pubspec.yaml`)**
    *   `google_generative_ai`: Gemini API 연동 코어
    *   `flutter_dotenv`: API 키 보호를 위한 환경 변수(` .env`) 처리
*   **API 관리 (`.env`)**
    *   루트 폴더에 `.env` 파일을 생성하고 `GEMINI_API_KEY` 환경변수에 키를 할당 (해당 파일은 `.gitignore` 처리되어 있어 안전)
    *   앱 진입점(`main.dart`)에서 `dotenv.load()` 실행.

## 2. 모듈별 구현 상세

### 2.1 GeminiVisionDatasource
이미지에서 제목 생성에 필요한 핵심 키워드를 추출합니다.
*   **사용 모델**: `gemini-1.5-flash`
*   **입력 데이터**: 사용자가 골라 넘긴 사진 파일(File 객체)을 바이트 배열(`DataPart('image/jpeg', bytes)`) 형태로 변환하여 전송.
*   **프롬프트 (Vision Prompt)**: 
    *   "이 이미지의 핵심 객체, 배경, 분위기, 행동 양상을 5~10개의 쉼표로 구분된 키워드로만 추출해줘. 친절한 서술이나 인사말 없이 키워드만."
*   **출력**: 전송받은 키워드 텍스트를 쉼표 `,` 로 파싱하여 `VisionResponseModel(extractedTags: List<String>)` 형태로 반환.

### 2.2 GeminiLlmDatasource
Vision에서 추출한 키워드(태그)와 선택된 분위기 프리셋을 조합하여 최종 제목 문장을 생성합니다.
*   **사용 모델**: `gemini-1.5-flash`
*   **입력 데이터**: 위에서 추출된 `List<String> tags`, 사용자가 선택한 UI 프리셋(`presetType` : 애니메이션, 픽셀아트, 수채화, 또는 향후 추가될 특정 컨셉들).
*   **고도화된 프롬프트 템플릿 (Preset 별 분기 로직 적용)**:
    *   **공통 지시사항**: "주어진 태그({tags})의 내용을 토대로 제목을 만들 것."
    *   **프리셋 A (열혈 배틀물)**: "90년대 일본 열혈 소년만화의 부제 같은 비장하고 중2병스러운 한국어 문장 딱 1개를 만들어줘. (예: 최후의 일격! 불타오르는 내 오른팔!)"
    *   **프리셋 B (러브 코미디)**: "요즘 라이트노벨 특유의 매우 길고 설명충 같으면서도 어이없는 서술형 제목 딱 1개를 한국어로 만들어줘."
    *   **프리셋 C (현대 판타지 등 기타)**: "웹소설 특유의 사이다 전개를 예고하는 듯한 직관적인 제목 1개를 뽑아줘."
*   **출력**: 최종 생성된 제목 텍스트(`title`)를 `LlmResponseModel`로 감싸 반환.

## 3. 작동 순서 및 검증 시나리오 (Verification)
1.  **UI**: `HomePage` 에서 이미지 선택 시 `gemini-1.5` 모델이 이를 분석.
2.  **데이터플로우**: `Vision API(태그 추출)` -> `LLM API(프롬프트 결합 및 자막 생성)` 파이프라인으로 연결.
3.  **결과 확인**: `ResultPage` 이동 시 스크래치 화면 렌더링. 생성된 결과 제목이 `CompositeTitle` 등 캔버스 조합부를 거쳐 정상적으로 표시되는지 확인.
4.  **보안 체크**: `.env` 파일과 API 키가 Git 등 외부에 노출되지 않도록 `flutter doctor` 및 파일 변경 내역 확인.
