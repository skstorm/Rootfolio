# Task List - Phase 3: AI 이미지 변환

> 의존: Phase 2 완료 필수
> 목표: 원본 사진을 애니메이션 스타일로 변환

---

## 3-1. ImageGen 모듈 Real 구현
> 의존: Phase 0 api_client.dart

### Data
- [ ] `stable_diffusion_datasource.dart`: SD API (img2img) 호출
  - 업로드 전 이미지 리사이즈 (최대 2048px)
  - 요청 타임아웃 30초
  - 응답 이미지 최소 512x512 보장
- [ ] `sd_response_model.dart`: API 응답 파싱
- [ ] `image_gen_repository_impl.dart`: Real 구현

### DI 교체
- [ ] injection_container.dart: MockImageGenRepository → ImageGenRepositoryImpl로 교체

### 파이프라인 수정
- [ ] AppController 수정: ImageGen → TitleAcademy 순서로 파이프라인 연결
  - 변환된 이미지를 TitleAcademy에 전달 (변환 이미지 기반 분석)

### 안전장치
- [ ] 부적절한 이미지 모더레이션 필터 (NSFW 체크)
- [ ] 변환 실패 시 원본 이미지로 폴백
- [ ] 대용량 이미지 메모리 관리 (리사이즈 + 캐시 해제)

### 테스트
- [ ] 리사이즈 로직 테스트 (다양한 해상도)
- [ ] 타임아웃 처리 테스트
- [ ] 폴백 로직 테스트 (API 실패 → 원본 사용)
- [ ] fixtures/sd_response.json 파싱 테스트

**Phase 3 완료 기준**:
- [ ] 원본 사진 → 애니 스타일 변환 동작
- [ ] 변환 시간 30초 이내
- [ ] 변환 실패 시 원본으로 정상 폴백
- [ ] 전체 플로우 재검증: 사진→변환→자막→스크래치→저장/공유
