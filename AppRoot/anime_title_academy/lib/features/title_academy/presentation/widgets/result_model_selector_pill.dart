import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/title_generation_model.dart';

class ResultModelSelectorPill extends StatelessWidget {
  const ResultModelSelectorPill({
    super.key,
    required this.selectedModel,
    required this.enabled,
    required this.onSelected,
  });

  final TitleGenerationModel selectedModel;
  final bool enabled;
  final ValueChanged<TitleGenerationModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TitleGenerationModel>(
      enabled: enabled,
      tooltip: '모델 선택',
      initialValue: selectedModel,
      onSelected: onSelected,
      itemBuilder: (context) => TitleGenerationModel.values
          .map(
            (model) => PopupMenuItem<TitleGenerationModel>(
              value: model,
              child: Text(model.displayLabel),
            ),
          )
          .toList(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.6,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: UiConstants.resultModelPillHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 8),
              Text(
                selectedModel.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.86),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
