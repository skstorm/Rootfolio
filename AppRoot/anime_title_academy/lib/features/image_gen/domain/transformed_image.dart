import 'dart:io';

class TransformedImage {
  final File file;
  final String style;
  final bool isOriginal; // 폴백 시 true

  const TransformedImage({
    required this.file,
    required this.style,
    this.isOriginal = false,
  });
}
