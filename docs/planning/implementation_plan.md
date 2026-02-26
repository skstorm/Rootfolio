# Rootfolio 상세 기획안 (Expert Refined)

## 1. 전문가 그룹 검토 의견 (Expert Review)

### 📐 기획 전문가 (Planning)
- **발견**: `WebRoot`와 `AppRoot` 분리는 좋으나, 사용자가 `AppRoot` 내부의 프로젝트를 웹에서 어떻게 탐색할지에 대한 지도가 필요함.
- **제안**: 자동 인덱싱 기능을 구현하여 `AppRoot`에 새 폴더만 만들어도 메인 페이지의 'App 쇼케이스' 섹션에 자동으로 카드가 생성되도록 설계함.

### 🎨 디자인 전문가 (Design)
- **발견**: '성장하는 뿌리'라는 테마를 시각적으로 구체화해야 함.
- **제안**: 단순한 다크 모드를 넘어, 배경에 은은한 'Roots' 패턴 애니메이션(SVG)을 적용하고, 포인트 컬러로 `#2ECC71`(Emerald Green)을 사용하여 '성취'와 '성장'을 상징함.

### 💻 구현 전문가 (Implementation)
- **발견**: `deploy-bridge`가 단순 복사일 경우 파일 경로(Absolute vs Relative) 문제가 발생할 수 있음.
- **제안**: 빌드 시 `BASE_URL`을 환경 변수로 주입하는 루틴을 브릿지 워크플로우에 포함하고, Vite의 `public` 폴더를 최종 통합 지점으로 확정함.

---

## 2. 상세 구현 명세

### 🏗️ 폴더 구조 (Expanded)
```text
Rootfolio/
├── WebRoot/             # Vite + Vanilla JS Project
│   ├── src/             # SPA Core Logic
│   ├── content/         # Markdown Base (studies, logs)
│   ├── public/          # Static assets & Apps (Bridge Destination)
│   └── index.html       # Entry Point
├── AppRoot/             # Sub-projects (Flutter, etc.)
│   └── [AppName]/       # Individual projects
├── docs/                # Project Documentation
│   └── planning/        # Planning & Architecture
└── .agent/              # Workflows & Instructions
```

### 🔗 연결 고리: Deploy-Bridge 상세
- **트리거**: `/deploy-app [AppName]` 명령어 실행.
- **프로세스**: 
  1. `AppRoot/[AppName]` 폴더에서 `flutter build web` 실행.
  2. 생성된 `build/web/`의 내용을 `WebRoot/public/apps/[AppName]/`으로 미러링.
  3. `WebRoot`의 `apps-metadata.json`을 업데이트하여 메인 대시보드에 신규 앱 노출.

### 💎 디자인 시스템 (Dark Premium)
- **Typography**: `Inter` (Sans-serif)를 기본으로, 제목은 `Outfit` (Geometric) 사용.
- **Color Palette**:
  - `bg-base`: `#0F172A` (Deep Slate)
  - `glass-bg`: `rgba(255, 255, 255, 0.05)` (Glassmorphism)
  - `accent`: `#10B981` (Vibrant Green)
- **Interactions**: 모든 카드와 버튼에 Subtle Hover Lift 효과와 광택(Reflective) 효과 적용.

## 3. 검증 전략

- **Step 1**: `WebRoot` 초기 레이아웃 구현 후 브라우저 서브 에이전트로 디자인 프리뷰 수행.
- **Step 2**: 빈 플러터 프로젝트를 `AppRoot`에 만들고 `deploy-bridge` 작동 여부 확인.
- **Step 3**: 모바일 반응형 레이아웃 뷰포트 테스트.
