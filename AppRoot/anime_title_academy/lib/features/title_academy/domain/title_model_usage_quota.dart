import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

class TitleModelUsageQuota {
  const TitleModelUsageQuota({
    required this.model,
    required this.dailyFreeCount,
    required this.dailyFreeRemaining,
    required this.rewardedRemaining,
    required this.rewardRechargeCount,
    required this.isBypassed,
  });

  final TitleGenerationModel model;
  final int dailyFreeCount;
  final int dailyFreeRemaining;
  final int rewardedRemaining;
  final int rewardRechargeCount;
  final bool isBypassed;
}
