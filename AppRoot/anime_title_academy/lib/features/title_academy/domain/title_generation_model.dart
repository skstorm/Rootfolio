enum TitleGenerationModel {
  fast(
    label: '빠름',
    modelName: 'gemini-2.5-flash-lite',
  ),
  balanced(
    label: '밸런스',
    modelName: 'gemini-2.5-flash',
  ),
  highQuality(
    label: '고품질',
    modelName: 'gemini-2.5-pro',
  );

  const TitleGenerationModel({
    required this.label,
    required this.modelName,
  });

  final String label;
  final String modelName;

  String get displayLabel => '$label ($modelName)';
}
