import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

class TitleUsageQuotaPolicy {
  const TitleUsageQuotaPolicy({
    required this.dailyFreeCount,
    required this.rewardRechargeCount,
  });

  final int dailyFreeCount;
  final int rewardRechargeCount;
}

const Map<TitleGenerationModel, TitleUsageQuotaPolicy> titleUsageQuotaPolicies = {
  TitleGenerationModel.fast: TitleUsageQuotaPolicy(
    dailyFreeCount: 5,
    rewardRechargeCount: 3,
  ),
  TitleGenerationModel.balanced: TitleUsageQuotaPolicy(
    dailyFreeCount: 3,
    rewardRechargeCount: 2,
  ),
  TitleGenerationModel.highQuality: TitleUsageQuotaPolicy(
    dailyFreeCount: 1,
    rewardRechargeCount: 2,
  ),
};
