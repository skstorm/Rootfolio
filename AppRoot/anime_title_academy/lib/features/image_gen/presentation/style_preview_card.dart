import 'dart:ui';
import 'package:flutter/material.dart';

class StylePreviewCard extends StatefulWidget {
  final String styleName;
  final String styleLabel;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const StylePreviewCard({
    super.key,
    required this.styleName,
    required this.styleLabel,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<StylePreviewCard> createState() => _StylePreviewCardState();
}

class _StylePreviewCardState extends State<StylePreviewCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: widget.isSelected 
                      ? Colors.yellowAccent.withOpacity(0.9) 
                      : Colors.white.withOpacity(0.08),
                  width: widget.isSelected ? 2.5 : 1.2,
                ),
                color: widget.isSelected 
                    ? Colors.yellowAccent.withOpacity(0.12) 
                    : Colors.white.withOpacity(0.04),
                boxShadow: widget.isSelected ? [
                  BoxShadow(
                    color: Colors.yellowAccent.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                  )
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // [MOD] 부모 너비 확장 대응을 위해 중앙 정렬
                children: [
                  Text(
                    widget.emoji, 
                    style: const TextStyle(fontSize: 26),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.styleLabel,
                    style: TextStyle(
                      color: widget.isSelected ? Colors.yellowAccent : Colors.white.withOpacity(0.8),
                      fontWeight: widget.isSelected ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
