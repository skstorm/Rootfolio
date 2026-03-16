import 'package:flutter/material.dart';

/// 앱 전체의 UI 가이드라인 및 조정 가능한 수치들을 모아놓은 설정 클래스입니다.
/// 모든 수치는 논리적 픽셀(Logical Pixels) 기준입니다.
class UiConstants {
  // --- [PC 실행 환경 설정] ---
  
  /// PC(Windows)에서 실행 시 앱 창의 너비입니다. 최신 스마트폰 비율을 반영합니다.
  static const double pcWindowWidth = 390.0; // iPhone 13/14 논리 너비
  
  /// PC(Windows)에서 실행 시 앱 창의 높이입니다.
  static const double pcWindowHeight = 844.0; // iPhone 13/14 논리 높이


  // --- [스크래치 영역 관련 설정] ---

  /// 애니메이션 제목이 표시되는 스크래치 영역의 고정 높이입니다.
  static const double scratchAreaHeight = 90.0;

  /// 스크래치 영역 내 제목 텍스트의 크기입니다.
  static const double scratchTitleFontSize = 20.0;

  /// 제목 텍스트의 색상입니다.
  static const Color scratchTitleColor = Colors.yellow;

  /// 스크래치 브러시의 너비입니다. 값이 작을수록 더 섬세하게 긁어야 합니다.
  static const double scratchStrokeWidth = 35.0; // 기존 50.0에서 축소

  /// 한 번의 터치로 마스크가 지워지는 강도(투명도)입니다. 
  /// 0.0 ~ 1.0 사이의 값을 가지며, 낮을수록 여러 번 긁어야 속이 보입니다.
  static const double scratchErasureIntensity = 0.4; // 긁는 맛을 위해 조정

  /// 전체 면적 중 몇 % 이상 긁어야 완료로 간주할지 정하는 임계치입니다. (0.0 ~ 1.0)
  static const double scratchTotalClearThreshold = 0.2;

  /// 텍스트 영역 중 몇 % 이상 노출되어야 완료로 간주할지 정하는 임계치입니다. (0.0 ~ 1.0)
  static const double scratchTextClearThreshold = 0.8; // 기존 0.6에서 0.8로 상향

  /// 스크래치 브러시 경계의 부드러움 정도(Blur Sigma)입니다.
  static const double scratchSoftBlurSigma = 12.0;


  // --- [텍스트 생성 제약 조건] ---

  /// AI가 생성할 수 있는 제목의 최대 글자 수입니다. (공백 포함)
  static const int maxTitleLength = 25; // 기존 18에서 25로 상향


  // --- [레이아웃 보정 수치] ---

  /// 디버그 오버레이가 스크래치 영역 위로 표시될 때의 수직 오프셋 값입니다.
  static const double debugOverlayTopOffset = -100.0;
}
