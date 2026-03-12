# Task List - Phase 2: 스크래치 UX

> 의존: Phase 1 완료 필수
> 목표: 결과물을 스크래치로 공개하는 손맛 UX 추가

---

## 2-1. ScratchUX 모듈 구현
> 의존: Phase 1 result_page.dart

### Core
- [ ] `scratch_painter.dart`: CustomPainter 구현
  - GestureDetector로 터치 좌표 수집
  - BlendMode.clear로 터치 경로 투명 처리
  - 투명 영역 비율(%) 실시간 계산
- [ ] `scratch_canvas.dart`: 터치 이벤트 처리 위젯
- [ ] `scratch_provider.dart`: 스크래치 진행 상태 관리

### 연출
- [ ] `scratch_wrapper_view.dart`: Front(가림막) + Back(결과물) 래핑
  - Front: 원본 사진 그레이스케일 버전
  - Back: 필터+자막 합성 결과
- [ ] `reveal_particle.dart`: 폭발 파티클 위젯
- [ ] `confetti_controller.dart`: Lottie 애니메이션 제어
- [ ] `assets/lottie/confetti.json`: 파티클 폭발 애니메이션 파일

### 통합
- [ ] result_page.dart 수정: 결과를 ScratchWrapperView로 래핑
- [ ] 40% 이상 긁으면 → 자동 전체 공개 + 파티클 폭발
- [ ] 스크래치 완료 후 → 저장/공유 버튼 활성화

### 테스트
- [ ] 퍼센트 계산 정확성 테스트 (0%, 39%, 40%, 100%)
- [ ] 임계값 도달 시 onClear 콜백 호출 확인
- [ ] 성능 테스트: 60fps 유지 확인 (저사양 기기)
- [ ] 앱 종료 후 재진입 시 결과 즉시 표시

**Phase 2 완료 기준**:
- [ ] 스크래치 터치 동작 정상
- [ ] 40% 긁으면 자동 공개 + 폭발 애니메이션
- [ ] 60fps 유지
- [ ] 전체 플로우 재검증: 사진→프리셋→생성→스크래치→저장/공유
