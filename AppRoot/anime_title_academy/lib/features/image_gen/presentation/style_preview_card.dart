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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected ? Colors.yellowAccent.withOpacity(0.8) : Colors.white24,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            color: widget.isSelected 
                ? Colors.yellowAccent.withOpacity(0.12) 
                : const Color(0xFF1E1E1E).withOpacity(0.6),
            boxShadow: widget.isSelected ? [
              BoxShadow(
                color: Colors.yellowAccent.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                widget.styleLabel,
                style: TextStyle(
                  color: widget.isSelected ? Colors.yellowAccent : Colors.white70,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
