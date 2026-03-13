import 'gallery_item.dart';

abstract class GalleryRepository {
  Future<List<GalleryItem>> getItems();
  Future<void> saveItem(GalleryItem item);
  Future<void> deleteItem(String id);
}
