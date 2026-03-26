/// 이미지 생성(Stable Diffusion 등)에 관련된 제한값과 제약조건을 모아둔 상수 파일입니다.
abstract final class ImageGenConstants {
  /// 사용자가 업로드/생성 요청할 수 있는 원본 이미지의 최대 허용 용량(MB) 제한입니다.
  /// 💡MVP 테스트 환경에서 트래픽 초과를 막기 위해 설정된 값입니다.
  static const double maxImageUploadSizeMB = 5.0; // MVP 이미지 용량 상한
}
