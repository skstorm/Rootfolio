import 'package:anime_title_academy/features/title_academy/domain/title_usage_quota_snapshot.dart';

enum QuotaConsumeStatus {
  bypassed,
  consumedFree,
  consumedRewarded,
  exhausted,
}

class QuotaConsumeResult {
  const QuotaConsumeResult({
    required this.status,
    required this.quota,
  });

  final QuotaConsumeStatus status;
  final TitleUsageQuotaSnapshot quota;

  bool get isAllowed => status != QuotaConsumeStatus.exhausted;
}
