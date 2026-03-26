import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';

/// 텍스트 생성 모델의 등급(Fast, Balanced, High Quality)별
/// 하루 무료 제공량과 보상형 광고 시청 시 충전되는 횟수 정책을 정의합니다.
class TitleUsageQuotaPolicy {
  const TitleUsageQuotaPolicy({
    required this.dailyFreeCount,
    required this.rewardRechargeCount,
  });

  /// 이 모델에 대해 매일 자정(KST 기점)에 무료로 리필되는 기본 사용 횟수입니다.
  final int dailyFreeCount;

  /// 이 모델에 대해 보상형 광고 1회 시청 완료 시 증가하는 사용 횟수입니다.
  final int rewardRechargeCount;
}

/// 앱 내에서 사용되는 모든 AI 모델의 할당량(Quota) 정책 튜닝 테이블입니다.
/// 💡이 값을 수정하면 다이얼로그, 로컬 스토리지 한도, 사용량 표시 등이 앱 전반에 즉각 반영됩니다.
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
