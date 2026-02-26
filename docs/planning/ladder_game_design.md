# 사다리타기 게임 (Ghost Leg) 상세 설계안 (Flutter Edition)

사용자님의 요청에 따라 **Flutter**를 기반으로, 확장성과 디자인 퍼포먼스를 극대화한 통합 설계안입니다.

---

## 1. 🛠️ 기술 스택 및 선정 이유
- **Framework**: Flutter Web (Rootfolio 배포 엔진과 최적화된 호환성)
- **Rendering**: `CustomPainter` (네온 효과, 파티클 등 고성능 그래픽 구현에 적합)
- **State Management**: `ChangeNotifier` + `Provider` (유연한 데이터 흐름 제어)

---

## 2. 모듈형 아키텍처 설계 (Logic & Visual Separation)

### 🧩 A. Game Engine (Logic)
- **동적 가로선 생성**: Y축 슬롯 기반의 충돌 방지 알고리즘을 사용하여 맵을 생성합니다.
- **경로 계산**: 특정 플레이어의 시작점부터 도착점까지의 모든 꺾임 지점을 좌표 리스트(`List<Offset>`)로 산출합니다.

### 🎨 B. Visual Renderer (Design) - "Electric Roots" 테마
- **선(Line) 스타일링**: 어두운 배경 위에 네온 그린 글로우 효과가 흐르는 전선/뿌리 스타일.
- **Juice & Polish**:
    - 가로선 교차 지점의 **Spark(스파크)** 파티클 효과.
    - 캐릭터 이동 시의 **Matrix4 기반 시네마틱 카메라 추적**.
    - 도착 시 화려한 **Confetti** 연출.

### 🎬 C. Controller & State
- **애니메이션 시퀀스**: `AnimationController`를 활용하여 각 구간별 리드미컬한 이동 속도를 제어합니다.
- **상태 머신**: `Setup` -> `Running` -> `Finished` 상태에 따른 상호작용 제한 및 UI 전환.

---

## 3. 커스텀 및 확장 기능

- **골(Goal) 종류**: 텍스트(꽝, 당첨), 과일 아이콘(사과, 포도 등) 리스트를 동적으로 대응합니다.
- **아이템 시스템(확장)**: 순간이동, 방향 전환 등 특수 노드 확장이 용이한 데이터 구조를 채택했습니다.

---

## 📂 파일 구조 계획
```text
AppRoot/ladder_game/
├── lib/
│   ├── engine/           # 사다리 생성 및 길찾기 로직
│   ├── renderer/         # CustomPaint 및 효과 드로잉
│   ├── providers/        # 게임 상태 관리
│   ├── widgets/          # UI 컴포넌트 (설정창, 결과창)
│   └── main.dart         # 게임 엔트리
├── assets/               # 이미지 및 아이콘
└── pubspec.yaml          # 패키지 설정
```

---

## 📍 문서 확인 안내
현재 이 문서는 프로젝트 폴더 내 다음 경로에 저장되어 있습니다:
**`e:\Study\Rootfolio\docs\planning\ladder_game_design.md`**

에디터 왼쪽의 파일 탐색기에서 위 경로를 직접 클릭하여 확인해 주시기 바랍니다.
