/// AI 파이프라인(Gemini Vision API 및 텍스트 생성기)과 관련된 글로벌 상수/제약조건 모음입니다.
/// 이미지 업로드 크기, 압축률, LLM 문자 수 제한 등을 튜닝할 수 있습니다.
abstract final class AiPipelineConstants {
  /// Vision 분석을 서버로 보내기 전, 모바일/PC 단말에서 미리 이미지를 리사이징할 때 사용하는 최대 긴 변의 길이(픽셀)입니다.
  /// 💡값을 줄이면 API 트래픽 및 지연 속도가 크게 감소하지만, 너무 작으면 AI가 텍스트/얼굴을 잘 인식하지 못할 수 있습니다.
  static const int visionMaxImageDimension = 768;

  /// Vision 분석용으로 이미지를 인코딩할 때 사용할 JPEG 압축 품질 (0 ~ 100)입니다.
  /// 💡보통 60~85 사이가 용량과 품질의 밸런스가 좋습니다.
  static const int visionJpegQuality = 65;
  
  /// AI가 생성해야 하는 애니메이션 제목의 최대 글자 수 제약조건입니다. (공백 포함)
  /// 💡이 수치는 프롬프트(PromptTemplateService)에 시스템 룰로 직접 주입되며, LLM의 출력을 제한합니다.
  static const int maxTitleLength = 25;
}
