import 'package:flutter/material.dart';

class TitleStyle {
  final double fontSize;
  final Offset position;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const TitleStyle({
    required this.fontSize,
    required this.position,
    this.fillColor = const Color(0xFFFFEB3B), // Yellow
    this.strokeColor = const Color(0xFF000000), // Black
    this.strokeWidth = 3.0,
  });
}
