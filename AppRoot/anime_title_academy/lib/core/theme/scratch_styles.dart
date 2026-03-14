import 'package:flutter/material.dart';

class ScratchStyles {
  /// 자막 영역 스크래치 마스크용 은색 펄 그라데이션
  static BoxDecoration silverMaskDecoration(int patternIndex) {
    // 패턴 인덱스에 따라 약간씩 다른 색감을 주어 유동적인 느낌 연출
    final colors = [
      [Colors.grey[400]!, Colors.grey[600]!, Colors.grey[300]!],
      [Colors.grey[500]!, Colors.grey[300]!, Colors.grey[700]!],
      [Colors.grey[600]!, Colors.grey[400]!, Colors.grey[500]!],
    ];
    
    final selectedColors = colors[patternIndex % colors.length];

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: selectedColors,
        stops: const [0.1, 0.5, 0.9],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 스크래치 마스크 위에 표시될 안내 텍스트 스타일
  static const TextStyle guideTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    shadows: [
      Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black45),
    ],
  );
}
