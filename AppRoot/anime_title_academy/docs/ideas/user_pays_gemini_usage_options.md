# 사용자 각자 비용 부담형 Gemini 사용 구조 검토

## 배경
- `anime_title_academy`는 현재 앱 소유의 API 키로 Gemini API를 호출한다.
- 목표는 가능한 경우 사용자가 자신의 자원으로 Gemini 호출 비용을 부담하게 만드는 것이다.
- Windows는 기존 API 키 기반 방식을 유지하고, 모바일/웹 중심으로 검토한다.

## 결론
- `Google 로그인`만으로 사용자의 개인 Gemini 플랜을 앱에서 그대로 사용하는 구조는 기대하면 안 된다.
- `사용자 각자 비용 부담`을 실현하려면 현실적으로는 `사용자 각자 API key 또는 Cloud project를 사용하게 하는 방식`이 필요하다.

## 핵심 정리

### 1. Google 로그인과 Gemini API 과금은 같은 개념이 아니다
- 사용자가 Google 계정으로 로그인하는 것은 인증 수단이다.
- Gemini API 과금과 쿼터는 일반적으로 `Google Cloud project` 단위로 관리된다.
- 따라서 사용자가 Google 계정으로 로그인했다고 해서, 그 사용자의 개인 Gemini 웹 서비스 구독이나 Gemini Advanced 플랜이 앱 호출 비용으로 직접 연결된다고 보긴 어렵다.

### 2. OAuth 기반 Gemini 호출은 가능할 수 있다
- `flutter_base`에는 Google 로그인 후 access token을 받아 Gemini REST API를 호출하는 구조가 있다.
- 이 구조는 모바일/웹 중심으로 활용 가능하다.
- 다만 이것은 "사용자 로그인 기반 인증"이지, "사용자의 개인 Gemini 소비자 플랜 사용"과는 다른 문제다.

### 3. 실제 과금 주체는 보통 프로젝트다
- Gemini API billing은 Cloud Billing과 연결된 프로젝트 기준으로 처리된다.
- 즉 API key 방식이든 OAuth 방식이든, 실제 비용 책임은 대개 해당 API 호출이 속한 Cloud project에 귀속된다.

## 가능한 선택지

### 선택지 A. 앱 소유 API key 유지
- 앱이 직접 API key를 보유하고 Gemini를 호출한다.
- 장점:
  - 구현이 가장 단순하다.
  - 현재 구조와 잘 맞는다.
- 단점:
  - 비용이 앱 운영자에게 집중된다.

### 선택지 B. 사용자 BYOK(Bring Your Own Key)
- 사용자가 자신의 Google AI Studio 또는 Cloud project에서 API key를 발급받아 앱에 입력한다.
- 앱은 입력된 사용자 키로 Gemini를 호출한다.
- 장점:
  - 비용과 쿼터가 사용자 측으로 넘어간다.
  - 현재 앱 구조와 가장 잘 맞는다.
  - Windows / 모바일 / 웹 공통 구조로 확장하기 쉽다.
- 단점:
  - 일반 사용자에게 설정 난이도가 높다.
  - API key 입력/저장 UX와 보안 처리가 필요하다.

### 선택지 C. 사용자 자신의 Cloud project + OAuth
- 사용자가 자기 Cloud project를 만들고 billing account를 연결한다.
- 앱은 OAuth 인증과 quota project 개념을 이용해 사용자의 프로젝트 기준으로 호출을 시도한다.
- 장점:
  - 원칙적으로는 사용자 프로젝트가 비용 주체가 될 수 있다.
- 단점:
  - 설정 난이도가 매우 높다.
  - 일반 사용자 앱 UX로는 부적합하다.
  - 운영, 지원, 문서화 비용이 크다.

### 선택지 D. Google 로그인만으로 사용자 개인 Gemini 플랜 사용
- 기대 구조:
  - 사용자가 Google 로그인만 하면
  - 그 계정의 Gemini Advanced 또는 개인 Gemini 플랜을 앱이 그대로 사용
- 판단:
  - 공식 문서 근거 기준으로는 기대하지 않는 것이 맞다.
  - 소비자용 Gemini 서비스와 개발자용 Gemini API는 과금 구조가 분리되어 있다고 보는 편이 안전하다.

## anime_title_academy 기준 추천
- Windows: 현재 방식 유지
  - 앱 소유 API key 사용
- 모바일/웹:
  - 현실적인 대안으로 `BYOK 모드`를 검토
  - 필요하면 이후에 Google 로그인은 별도 편의 기능으로 추가하되, 과금 책임 분리는 API key 기준으로 처리

## 추천 방향
1. 단기:
   - 앱 소유 API key 유지
   - 고품질 모드, 모델 선택 UX, 로딩 UX 개선
2. 중기:
   - `사용자 API key 입력` 기능 추가
   - 앱 소유 키 / 사용자 키 선택 모드 제공
3. 장기:
   - 모바일/웹에서 OAuth 기반 호출 필요성 재검토
   - 하지만 비용 책임 분리는 OAuth보다 BYOK가 더 현실적

## 메모
- "사용자 각자 비용 부담"을 제품적으로 실현하려면, 가장 실용적인 해법은 `사용자별 API key 사용`이다.
- Google 로그인은 인증 편의성에는 도움을 줄 수 있어도, 비용 주체를 자동으로 사용자 개인 Gemini 플랜으로 넘기는 해법은 아니다.
