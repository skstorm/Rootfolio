class ImageAnalysis {
  final List<String> tags;
  final double confidence;

  const ImageAnalysis({
    required this.tags,
    this.confidence = 1.0,
  });

  bool get isEmpty => tags.isEmpty;
}
