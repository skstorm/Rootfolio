# Anime Title Academy 결과 화면 Floating Island UI/UX 개선 구현 계획서

## 문서 목적
- 현재 `ResultPage` 하단 액션 버튼 영역이 텍스트 길이와 버튼 수 증가로 인해 잘리거나 답답하게 보이는 문제를 해결한다.
- `저장 / 공유 / 다시하기 / 자막 재생성` 계열 액션을 하나의 `Floating Island`로 재구성한다.
- 모바일과 데스크톱에서 같은 UI 구조를 유지하되, 입력 방식 차이만 반영한다.
- 이 문서를 기준으로 실제 리뉴얼 구현을 진행한다.

## 현재 문제 요약
- 하단 버튼이 텍스트 중심이라 가로 폭을 많이 차지한다.
- 버튼 수가 늘어나면 한 줄에 담기 어렵고, 현재 화면처럼 일부가 잘려 보인다.
- `모델 선택`과 `액션 버튼`의 성격이 다른데, 현재는 하단에 함께 몰려 있어 정보 구조가 다소 혼잡하다.
- 앞으로 기능이 추가되면 버튼 수가 더 늘어날 가능성이 높아 현재 구조의 확장성이 낮다.

## 이번 작업의 확정 방향

### 1. 모바일과 데스크톱은 같은 UI 구조를 사용한다
- 시각 구조는 동일하게 유지한다.
- 차이는 상호작용만 둔다.
  - 데스크톱: hover 기반 라벨 표시
  - 모바일: long press 기반 라벨 표시

### 2. `모델 선택`은 항상 보이는 독립 pill로 유지한다
- 하단 메인 액션 아일랜드와 분리한다.
- 이유:
  - 모델 선택은 실행 액션이 아니라 생성 품질/비용을 정하는 설정에 가깝다.
  - `저장 / 공유 / 다시하기 / 자막 재생성`과 같은 레벨로 섞으면 향후 quota 문구와 함께 복잡도가 높아진다.

### 3. `디버그`는 계속 상단 우측 독립 영역에 둔다
- 일반 사용자 액션과 같은 그룹에 넣지 않는다.
- 개발용 컨트롤은 현재처럼 항시 표시하되, 메인 플로우의 액션 도크에는 포함하지 않는다.

### 4. 메인 액션은 하단 `Floating Island`로 묶는다
- 대상:
  - 저장
  - 공유
  - 다시하기
  - 자막 재생성
- 기본은 아이콘만 노출한다.
- 라벨은 버튼 내부에 항상 쓰지 않고, 포인터 진입 또는 길게 누르기 시에만 별도 버블로 보여준다.

### 5. 버튼이 4개를 넘으면 스크롤 가능한 도크로 확장한다
- 4개까지는 한 화면에 자연스럽게 보이도록 설계한다.
- 5개 이상부터는 가로 스크롤 가능한 구조로 바꾼다.
- 사용자가 더 있다는 것을 인지할 수 있도록 좌우 방향 affordance를 제공한다.

## 목표 UX 구조

### 상단 영역
- 뒤로 가기
- 제목
- 디버그 버튼
- 디버그 샌드박스 버튼

### 하단 영역
- 1단:
  - `모델 선택 pill`
  - quota 요약 문구
- 2단:
  - `Floating Island action dock`

권장 시각 구조:

```text
[ 결과 이미지 / 스크래치 영역 ]

          [ 빠름 v ]   <- 독립 pill
   무료 n회 / 충전 n회 / 광고 1회로 n회 충전

   [  island:  save | share | retry | regen  ]
```

## Floating Island 설계

### 핵심 스타일
- 화면 하단 중앙 정렬
- 둥근 캡슐형 컨테이너
- 반투명 dark surface
- 밝은 외곽선 또는 아주 약한 inner highlight
- 배경과 분리되는 부드러운 그림자
- 결과 화면 전체 톤에 맞는 subdued gold / charcoal 포인트 유지

### 기본 레이아웃
- 가로 스크롤 가능한 `horizontal dock`
- 버튼은 고정 width가 아닌 `정사각형 또는 거의 정사각형`
- 기본 상태에서는 아이콘만 렌더링
- 선택/비활성/로딩 상태는 색과 opacity로만 구분

### 버튼 라벨 표시 원칙
- 버튼 안에 항상 텍스트를 넣지 않는다.
- 라벨은 overlay bubble 또는 tooltip bubble로 표시한다.
- 버튼 폭은 라벨 표시 여부와 무관하게 고정 유지한다.

권장 라벨 위치:
- 버튼 위쪽 중앙
- 작은 pill 형태
- 짧은 한국어 단어 사용
  - 저장
  - 공유
  - 다시하기
  - 자막 재생성

## 입력 방식별 인터랙션

### 데스크톱
- mouse hover:
  - 라벨 bubble 표시
  - 아이콘 background highlight
- click:
  - 즉시 액션 실행
- wheel 또는 trackpad horizontal scroll:
  - 도크 스크롤 가능
- 버튼 수가 5개 이상일 때:
  - 좌우 화살표를 조건부 노출
  - 화살표 클릭으로 한 버튼 단위 또는 일정 거리만큼 이동

### 모바일
- tap:
  - 즉시 액션 실행
- long press:
  - 라벨 bubble 표시
- horizontal swipe:
  - 도크 스크롤
- 버튼 수가 5개 이상일 때:
  - 좌우 화살표를 항상 강제하지는 않음
  - 우선순위는 `스크롤 + 양끝 페이드`

## 스크롤 규칙

### 4개 이하
- 모든 버튼이 한 화면 안에 자연스럽게 보이도록 배치
- 스크롤 비활성화 또는 스크롤 가능하더라도 overflow 없음

### 5개 이상
- 도크를 가로 스크롤 가능 상태로 전환
- 오른쪽 또는 왼쪽에 더 버튼이 있으면:
  - 양끝 페이드 표시
  - 데스크톱에서는 좌우 화살표도 함께 표시

### 스크롤 affordance 우선순위
1. 다음 버튼이 일부 살짝 보이게 하는 레이아웃
2. 양끝 gradient fade
3. 데스크톱 한정 화살표 버튼

## 정보 구조 원칙

### `모델 선택`을 도크 밖에 두는 이유
- 메인 도크는 결과물에 대해 취하는 행동만 담당한다.
- 모델 선택은 생성 전/재생성 전 품질 설정이다.
- 이 둘을 분리하면 향후 추가될 항목과도 잘 맞는다.

### 액션 카테고리 정의
- 결과물 액션:
  - 저장
  - 공유
  - 다시하기
  - 자막 재생성
- 시스템/개발 액션:
  - 디버그
  - 프롬프트 샌드박스
- 설정/상태 액션:
  - 모델 선택
  - quota 정보

## 상태별 동작 정책

### 공통
- `isBusy`일 때는 실행 버튼들을 비활성화한다.
- `isCleared`가 아니면 저장/공유는 비활성화한다.
- 비활성 버튼도 아이콘은 보이되 opacity를 낮춘다.
- 비활성 상태에서도 hover/long-press 라벨은 보여줄 수 있다.
  - 예: `스크래치를 완료하면 저장 가능`

### 권장 세부 정책
- 저장:
  - `isCleared == true`일 때만 활성
- 공유:
  - `isCleared == true`일 때만 활성
- 다시하기:
  - 이미지가 있고 `!isBusy`일 때 활성
- 자막 재생성:
  - 현재 `titleViewState != null && !isBusy`일 때 활성

## 구현 대상 컴포넌트 제안

### 1. `ResultActionDock`
- 위치:
  - `lib/features/title_academy/presentation/widgets/result_action_dock.dart`
- 책임:
  - 하단 floating island 컨테이너
  - 버튼 목록 렌더링
  - 스크롤 처리
  - 좌우 화살표 표시 여부 판단
  - fade overlay 표시

### 2. `ResultActionDockButton`
- 위치:
  - `lib/features/title_academy/presentation/widgets/result_action_dock_button.dart`
- 책임:
  - 아이콘 전용 버튼 UI
  - hover / long-press 상태 처리
  - 라벨 bubble 노출
  - disabled / active / pressed 스타일 처리

### 3. `ResultModelSelectorPill`
- 위치:
  - `lib/features/title_academy/presentation/widgets/result_model_selector_pill.dart`
- 책임:
  - 현재 모델 표시
  - 모델 선택 팝업 메뉴
  - 액션 도크와 분리된 independent pill 렌더링

### 4. `ResultQuotaSummary`
- 위치:
  - `lib/features/title_academy/presentation/widgets/result_quota_summary.dart`
- 책임:
  - quota 문구 렌더링
  - bypass/debug/ad mode 문구 표시

## 기존 파일 변경 범위

### 핵심 수정 파일
- `lib/features/title_academy/presentation/result_page.dart`
  - 하단 버튼 레이아웃 제거
  - 새 pill + quota + dock 구조로 교체

### 보조 수정 가능 파일
- `lib/core/constants/ui_constants.dart`
  - dock height
  - dock padding
  - button size
  - label bubble offset
  - scroll threshold 관련 수치 추가

- `lib/core/theme/app_colors.dart`
  - floating island 배경/outline/highlight 색상 보강 가능

- `lib/core/theme/app_theme.dart`
  - 필요 시 공용 shadow 또는 surface tone 보강

## 구현 단계

### Phase A. 구조 분리
1. `result_page.dart` 하단 액션 영역을 작은 위젯들로 분리
2. `모델 선택 pill`, `quota summary`, `action dock`를 각각 독립 컴포넌트로 분리

### Phase B. Floating Island 도입
1. 하단 capsule 컨테이너 구현
2. 아이콘 전용 버튼 UI 구현
3. hover / long-press 라벨 bubble 구현
4. disabled / pressed / hover 시각 상태 구현

### Phase C. 확장성 대응
1. horizontal scroll controller 추가
2. 버튼 5개 이상일 때 overflow 감지
3. 양끝 fade 표시
4. 데스크톱 전용 좌우 화살표 표시

### Phase D. 정책 반영
1. `저장 / 공유 / 다시하기 / 자막 재생성` 액션 연결
2. `isBusy`, `isCleared` 상태를 버튼 활성화 정책에 연결
3. 기존 디버그/모델 선택 기능과 충돌 없도록 정리

### Phase E. 마감 품질 보정
1. Windows 화면에서 잘림 여부 재점검
2. 모바일 높이에서도 하단 여백 및 손가락 터치 영역 검증
3. 스크래치 완료 전후 상태 차이 시각적 확인

## 기술 구현 메모

### hover와 long-press를 함께 처리하는 방식
- `MouseRegion`으로 hover 감지
- `GestureDetector` 또는 `InkResponse`로 long-press 감지
- 같은 내부 state를 공유하여 라벨 bubble 표시

### overlay bubble 구현 방식
- 버튼 위에 `Stack` + `Positioned`로 올려도 되고,
- 도크 전체 기준 `OverlayPortal` 또는 로컬 overlay 형태로 처리해도 된다.
- 1차 구현은 복잡도를 줄이기 위해 각 버튼 내부 `Stack` 방식이 적합하다.

### 스크롤 감지
- `ScrollController` 사용
- 현재 offset 기준으로:
  - 좌측 hidden 존재 여부
  - 우측 hidden 존재 여부
  - 화살표 표시 여부 갱신

### 반응형 규칙
- 모바일과 데스크톱 구조는 동일
- 단, 터치 타겟은 모바일에서 더 넉넉하게 유지
- 라벨 bubble은 화면 하단에 닿지 않도록 위쪽으로 표시

## 시각적 디테일 가이드
- 도크는 완전 검은색보다 `짙은 회색 + 약한 투명도`가 좋다.
- 현재 결과 화면의 골드/옐로우 톤과 충돌하지 않도록 포인트 컬러는 제한적으로 사용한다.
- `자막 재생성`은 AI 액션이므로 약한 gold accent를 줄 수 있다.
- `저장/공유`는 중립색 기반으로 두고, hover 시만 강조한다.
- `다시하기`는 destructive가 아니라 neutral secondary action으로 유지한다.

## 이번 작업에서 하지 않을 것
- 저장/공유의 실제 기능 완성
- quota 정책 변경
- 디버그 버튼 위치 변경
- 모델 선택 정책 변경
- 결과 이미지/스크래치 영역 자체 레이아웃 대수술

## 완료 기준
- 하단 액션 영역이 더 이상 잘리지 않는다.
- 기본 상태에서 버튼은 아이콘만 보인다.
- 데스크톱 hover 시 라벨이 나타난다.
- 모바일 long-press 시 라벨이 나타난다.
- `모델 선택`은 메인 도크와 분리된 독립 pill로 보인다.
- `저장 / 공유 / 다시하기 / 자막 재생성`은 하나의 floating island 안에 정리된다.
- 5개 이상 버튼 확장 시 horizontal scroll 구조가 유지된다.
- 데스크톱에서는 필요 시 좌우 화살표가 노출된다.

## 작업 후 검증 항목
- Windows 데스크톱에서 결과 화면 하단 잘림이 사라졌는지
- hover 라벨이 도크 레이아웃을 밀지 않는지
- 모바일 터치 영역이 너무 작지 않은지
- `isBusy` 상태에서 중복 클릭이 방지되는지
- `isCleared` 전에는 저장/공유가 비활성인지
- `다시하기`, `자막 재생성`이 기존 로직과 동일하게 동작하는지

## 한 줄 요약
- 결과 화면 하단 액션 영역을 `텍스트 버튼 묶음`에서 `아이콘 중심의 스크롤 가능한 Floating Island 도크`로 재설계하고, `모델 선택`은 그 위의 독립 pill로 분리한다.
