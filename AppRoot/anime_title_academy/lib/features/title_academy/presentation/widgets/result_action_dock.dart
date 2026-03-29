import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/theme/app_colors.dart';

class ResultActionDockItem {
  const ResultActionDockItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? accentColor;
}

class ResultActionDock extends StatefulWidget {
  const ResultActionDock({
    super.key,
    required this.items,
  });

  final List<ResultActionDockItem> items;

  @override
  State<ResultActionDock> createState() => _ResultActionDockState();
}

class _ResultActionDockState extends State<ResultActionDock> {
  final ScrollController _scrollController = ScrollController();

  bool _hasOverflow = false;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  bool get _showDesktopArrows {
    if (kIsWeb) {
      return true;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows => true,
      TargetPlatform.macOS => true,
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  @override
  void didUpdateWidget(covariant ResultActionDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollState)
      ..dispose();
    super.dispose();
  }

  void _updateScrollState() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final hasOverflow = position.maxScrollExtent > 0;
    final canScrollLeft = position.pixels > 4;
    final canScrollRight = position.pixels < position.maxScrollExtent - 4;

    if (_hasOverflow == hasOverflow &&
        _canScrollLeft == canScrollLeft &&
        _canScrollRight == canScrollRight) {
      return;
    }

    setState(() {
      _hasOverflow = hasOverflow;
      _canScrollLeft = canScrollLeft;
      _canScrollRight = canScrollRight;
    });
  }

  Future<void> _scrollBy(double delta) async {
    if (!_scrollController.hasClients) {
      return;
    }
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showArrows = _showDesktopArrows && _hasOverflow;
    final useEvenSpacing = !_hasOverflow && widget.items.length <= 4;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UiConstants.resultActionDockHeight),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: UiConstants.resultActionDockHeight,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.surfaceDark.withValues(alpha: 0.68),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: showArrows ? 44 : 14,
                        vertical: 10,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (useEvenSpacing) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (final item in widget.items)
                                  Flexible(
                                    child: Center(
                                      child: _ResultActionDockButton(item: item),
                                    ),
                                  ),
                              ],
                            );
                          }

                          return SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: Row(
                                children: [
                                  for (var i = 0; i < widget.items.length; i++) ...[
                                    _ResultActionDockButton(item: widget.items[i]),
                                    if (i != widget.items.length - 1)
                                      const SizedBox(
                                        width: UiConstants.resultActionButtonGap,
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IgnorePointer(
                      child: Row(
                        children: [
                          _DockEdgeFade(
                            visible: _hasOverflow && _canScrollLeft,
                            alignment: Alignment.centerLeft,
                          ),
                          const Spacer(),
                          _DockEdgeFade(
                            visible: _hasOverflow && _canScrollRight,
                            alignment: Alignment.centerRight,
                          ),
                        ],
                      ),
                    ),
                    if (showArrows && _canScrollLeft)
                      Positioned(
                        left: 6,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _DockArrowButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: () => _scrollBy(-180),
                          ),
                        ),
                      ),
                    if (showArrows && _canScrollRight)
                      Positioned(
                        right: 6,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _DockArrowButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: () => _scrollBy(180),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultActionDockButton extends StatelessWidget {
  const _ResultActionDockButton({
    required this.item,
  });

  final ResultActionDockItem item;

  @override
  Widget build(BuildContext context) {
    final enabled = item.onPressed != null;
    final accent = item.accentColor ?? Colors.white;

    return Tooltip(
      message: item.label,
      preferBelow: false,
      verticalOffset: 18,
      waitDuration: const Duration(milliseconds: 250),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: item.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: item.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: UiConstants.resultActionButtonSize,
              height: UiConstants.resultActionButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: enabled
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Icon(
                item.icon,
                color: enabled
                    ? accent.withValues(alpha: 0.96)
                    : Colors.white.withValues(alpha: 0.28),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockArrowButton extends StatelessWidget {
  const _DockArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
    );
  }
}

class _DockEdgeFade extends StatelessWidget {
  const _DockEdgeFade({
    required this.visible,
    required this.alignment,
  });

  final bool visible;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: visible ? 1 : 0,
      child: Container(
        width: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: alignment == Alignment.centerLeft
                ? Alignment.centerLeft
                : Alignment.centerRight,
            end: alignment == Alignment.centerLeft
                ? Alignment.centerRight
                : Alignment.centerLeft,
            colors: [
              AppColors.surfaceDark.withValues(alpha: 0.72),
              AppColors.surfaceDark.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
