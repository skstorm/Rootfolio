import 'package:injectable/injectable.dart';

import 'vision_response_model.dart';

@lazySingleton
class ImageAnalysisCache {
  final Map<String, VisionResponseModel> _cache = {};

  VisionResponseModel? get(String key) => _cache[key];

  void put(String key, VisionResponseModel value) {
    _cache[key] = value;
  }

  void clear() {
    _cache.clear();
  }
}
