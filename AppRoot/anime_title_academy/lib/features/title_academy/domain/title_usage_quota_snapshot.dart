import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_model_usage_quota.dart';

class TitleUsageQuotaSnapshot {
  const TitleUsageQuotaSnapshot({
    required this.quotas,
    required this.isBypassed,
    required this.lastResetDateKey,
  });

  final Map<TitleGenerationModel, TitleModelUsageQuota> quotas;
  final bool isBypassed;
  final String lastResetDateKey;

  TitleModelUsageQuota forModel(TitleGenerationModel model) => quotas[model]!;
}
