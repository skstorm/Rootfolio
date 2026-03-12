# 모듈 상세 계획서: ImageGen (이미지 필터)

## 개요
원본 이미지를 애니메이션/판타지 등 스타일로 변환하는 모듈. Phase 3까지 Mock.

---

## 인터페이스

```dart
abstract class ImageEngine {
  Future<Result<File>> transformImage({
    required File source,
    required String stylePrompt,
  });
  List<String> get availableStyles; // ['anime', 'pixel_art', 'watercolor']
}
```

## 내부 구조

```
features/image_gen/
├── domain/
│   ├── entities/
│   │   └── transformed_image.dart
│   ├── repositories/
│   │   └── image_gen_repository.dart
│   └── usecases/
│       └── transform_image.dart
├── data/
│   ├── datasources/
│   │   └── stable_diffusion_datasource.dart
│   ├── models/
│   │   └── sd_response_model.dart
│   └── repositories/
│       ├── image_gen_repository_impl.dart
│       └── mock_image_gen_repository.dart   # 원본 그대로 반환
└── presentation/
    ├── providers/
    │   └── image_gen_provider.dart
    └── widgets/
        └── style_preview_card.dart
```

## 외부 의존성

| 패키지/서비스 | 용도 |
|--------------|------|
| Stable Diffusion API (img2img) | 스타일 변환 |
| image 패키지 | 로컬 리사이즈/전처리 |

## Mock 구현 (Phase 1-2)

```dart
class MockImageGenRepository implements ImageGenRepository {
  Future<Result<File>> transformImage({...}) async {
    return Success(source); // 원본 그대로 반환
  }
}
```

## Phase 진화

| Phase | 상태 | 설명 |
|-------|------|------|
| Phase 1-2 | Mock | 원본 이미지 그대로 반환 |
| Phase 3 | Real | SD API 연동, 스타일 1종(anime) |
| 이후 | 확장 | 스타일 추가 (pixel_art, watercolor 등) |

## 기술적 고려사항

- 업로드 전 이미지 리사이즈 (최대 2048px) → 메모리/전송 시간 최적화
- 변환 타임아웃 30초, 초과 시 에러 반환
- 변환 결과 최소 해상도 512x512 보장
- 부적절 이미지 모더레이션 (NSFW 필터)

## 테스트 포인트

- Mock이 원본을 정확히 반환하는지
- 리사이즈 로직 (다양한 해상도 입력)
- 타임아웃 처리
- 대용량 이미지 메모리 관리
