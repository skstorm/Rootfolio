

/// 앱 전체의 UI 가이드라인 및 조정 가능한 수치들을 모아놓은 설정 클래스입니다.
/// 모든 수치는 논리적 픽셀(Logical Pixels) 기준입니다.
class UiConstants {
  // --- [PC 실행 환경 설정] ---
  
  /// PC(Windows)에서 실행 시 앱 창의 너비입니다. 최신 스마트폰 비율을 반영합니다.
  static const double pcWindowWidth = 390.0; // iPhone 13/14 논리 너비
  
  /// PC(Windows)에서 실행 시 앱 창의 높이입니다.
  static const double pcWindowHeight = 844.0; // iPhone 13/14 논리 높이

  // --- [홈 화면 레이아웃 설정] ---

  /// 홈 화면 상단 헤더 영역의 높이 비율 (전체 높이 대비)
  static const double homeHeaderHeightRatio = 0.15;

  /// 홈 화면 메인 비주얼(아이콘)의 최대 높이 비율
  static const double homeMainVisualHeightRatio = 0.25;

  /// 홈 화면 스타일 카드 섹션의 높이 비율
  static const double homeStyleSectionHeightRatio = 0.2;

  /// 홈 화면 기본 수평 패딩 (수직 배치 시 좌우 여백 확보)
  static const double homeHorizontalPadding = 32.0;

  /// 하단 액션 버튼의 여백 (SafeArea 상단 기준)
  static const double homeBottomActionPadding = 32.0;

  /// 스타일 카드 사이의 수직 간격
  static const double homeStyleCardVerticalSpacing = 16.0;

  // --- [디버그 설정] ---

  /// 긁힌 영역을 연두색 점으로 표시할지 여부입니다.
  static const bool showDebugHitGrids = false; // 사용자의 요청으로 일단 Off

  /// 디버그 오버레이가 스크래치 영역 위로 표시될 때의 수직 오프셋 값입니다.
  static const double debugOverlayTopOffset = -100.0;
}
