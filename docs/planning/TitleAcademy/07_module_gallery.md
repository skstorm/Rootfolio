# 모듈 상세 계획서: Gallery (갤러리/히스토리)

## 개요
생성 결과 히스토리 로컬 저장, 조회, 삭제, 재생성.

---

## 인터페이스

```dart
abstract class GalleryRepository {
  Future<Result<List<GalleryItem>>> getHistory({int page, int limit});
  Future<Result<void>> saveItem(GalleryItem item);
  Future<Result<void>> deleteItem(String id);
  Future<Result<GalleryItem>> getItem(String id);
}

class GalleryItem {
  final String id;
  final File originalImage;
  final File resultImage;
  final String generatedTitle;
  final String presetUsed;
  final DateTime createdAt;
}
```

## 구현

```
features/gallery/
├── domain/
│   ├── entities/
│   │   └── gallery_item.dart
│   └── repositories/
│       └── gallery_repository.dart
├── data/
│   ├── local/
│   │   └── hive_gallery_datasource.dart  # Hive 로컬 DB
│   └── repositories/
│       └── gallery_repository_impl.dart
└── presentation/
    ├── pages/
    │   └── gallery_page.dart             # 그리드 뷰
    └── widgets/
        └── gallery_item_card.dart
```

## Phase: Phase 1부터 기본 저장/조회

## 테스트 포인트
- 저장/조회/삭제 CRUD 동작
- 페이지네이션
- DB 마이그레이션 (앱 업데이트 시)
