import '../domain/gallery_item.dart';
import '../domain/gallery_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: GalleryRepository)
class GalleryRepositoryImpl implements GalleryRepository {
  final List<GalleryItem> _mockStorage = [];

  @override
  Future<void> deleteItem(String id) async {
    _mockStorage.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<GalleryItem>> getItems() async {
    return List.unmodifiable(_mockStorage);
  }

  @override
  Future<void> saveItem(GalleryItem item) async {
    _mockStorage.insert(0, item);
  }
}
