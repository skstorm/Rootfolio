import 'package:flutter/material.dart';

/// 앱 내 스크래치 UX(복권 긁기 효과)와 관련된 모든 수치를 정의한 상수 모음입니다.
/// 이 값들을 수정하면 스크래치를 긁을 때의 지워지는 양, 텍스트 크기, 
/// 어느 정도 긁었을 때 완료 처리될지 등의 난이도를 조절할 수 있습니다.
abstract final class ScratchConstants {
  /// 스크래치가 표시될 전체 영역의 고정 높이입니다.
  static const double areaHeight = 90.0;

  /// 스크래치를 긁었을 때 나타나는 애니메이션 제목의 폰트 크기입니다.
  static const double titleFontSize = 20.0;

  /// 나타나는 애니메이션 제목의 폰트 색상(프리미엄한 노란색)입니다.
  static const Color titleColor = Colors.yellow;

  /// 스크래치 브러시의 너비(두께)입니다. 
  /// 💡값이 작을수록 훨씬 꼼꼼하고 여러 번 긁어야 내용이 보입니다.
  static const double strokeWidth = 35.0;

  /// 한 번의 터치로 마스크가 지워지는 강도(투명도, 0.0 ~ 1.0)입니다.
  /// 💡값이 낮을수록 여러 번 겹쳐서 긁어야 속이 완전히 투명해집니다.
  static const double erasureIntensity = 0.4;

  /// 스크래치 전체 면적 대비 몇 % 이상을 긁어야 "완료" 애니메이션으로 넘어갈지 정하는 임계치 (0.0 ~ 1.0)입니다.
  static const double totalClearThreshold = 0.2;

  /// 제목 텍스트가 표시된 영역 대비 몇 % 이상이 노출되어야 "완료"로 간주할지 정하는 임계치 (0.0 ~ 1.0)입니다.
  /// 💡사용자가 텍스트 주변부만 긁었을 때 유효 판정을 내리는 주요 수치입니다.
  static const double textClearThreshold = 0.8;

  /// 스크래치 브러시 경계면의 부드러움(Blur Sigma) 정도입니다.
  /// 💡값이 클수록 지운 경계선이 날카롭지 않고 부드럽게 퍼집니다.
  static const double softBlurSigma = 12.0;
}
