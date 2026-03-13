import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    );
  }

  /// 애니메이션 제목에 사용될 옐로우+블랙아웃라인 텍스트 스타일 정의
  static TextStyle get animeTitleStyle {
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      fontFamily: 'NanumSquare', // TODO: 향후 애니메이션 감성의 폰트로 교체될 수 있음
      color: AppColors.textTitleFill,
      shadows: [
        Shadow(
          // 좌하
          offset: Offset(-1.5, -1.5),
          color: AppColors.textTitleStroke,
        ),
        Shadow(
          // 우하
          offset: Offset(1.5, -1.5),
          color: AppColors.textTitleStroke,
        ),
        Shadow(
          // 우상
          offset: Offset(1.5, 1.5),
          color: AppColors.textTitleStroke,
        ),
        Shadow(
          // 좌상
          offset: Offset(-1.5, 1.5),
          color: AppColors.textTitleStroke,
        ),
      ],
    );
  }
}
