import 'package:flutter/material.dart';

class ResultQuotaSummary extends StatelessWidget {
  const ResultQuotaSummary({
    super.key,
    required this.summaryText,
    this.rewardText,
    this.modeText,
    this.isError = false,
  });

  final String summaryText;
  final String? rewardText;
  final String? modeText;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final summaryColor = isError ? Colors.redAccent : Colors.white70;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          summaryText,
          style: TextStyle(
            color: summaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (rewardText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              rewardText!,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (modeText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              modeText!,
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
