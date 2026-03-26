import '../domain/title_generation_model.dart';
import '../domain/title_usage_quota_service.dart';
import '../../../core/ads/ad_service.dart';

/// quota 확인 → 광고 시청 → 충전 → 파이프라인 실행 오케스트레이션을 담당하는 UseCase.
///
/// 비즈니스 로직만 담당하며, UI(dialog, snackbar)는 콜백으로 위임합니다.
class QuotaGatedPipelineUseCase {
  final TitleUsageQuotaService _quotaService;
  final AdService _adService;

  QuotaGatedPipelineUseCase({
    required TitleUsageQuotaService quotaService,
    required AdService adService,
  })  : _quotaService = quotaService,
        _adService = adService;

  /// quota가 허용될 때 [onAllowed]를 실행합니다.
  ///
  /// quota가 부족하면 [onNeedAd]를 호출합니다.
  /// - [onNeedAd]: 사용자에게 광고 시청을 요청하는 콜백. true 반환 시 광고를 시도합니다.
  /// - [onMessage]: 사용자에게 메시지를 전달하는 콜백 (스낵바 등).
  ///
  /// 반환값: 파이프라인이 실행되면 true, 중단되면 false.
  Future<bool> execute({
    required TitleGenerationModel model,
    required Future<void> Function() onAllowed,
    required Future<bool> Function() onNeedAd,
    required void Function(String message) onMessage,
  }) async {
    // 1. Quota 소비 시도
    final consumeResult = await _quotaService.consume(model);

    if (consumeResult.isAllowed) {
      await onAllowed();
      return true;
    }

    // 2. Quota 부족 → 광고 시청 요청
    final shouldWatchAd = await onNeedAd();
    if (!shouldWatchAd) {
      return false;
    }

    // 3. 광고 시청
    final adResult = await _adService.showRewardedAd(model: model);

    if (!adResult.isRewarded) {
      onMessage(adResult.message ?? '광고 시청이 완료되지 않았습니다.');
      return false;
    }

    // 4. 광고 성공 → Quota 충전
    await _quotaService.reward(model);

    // 5. 충전 후 재시도
    final retryConsume = await _quotaService.consume(model);
    if (!retryConsume.isAllowed) {
      onMessage('충전 후에도 사용권을 확보하지 못했습니다.');
      return false;
    }

    // 6. 파이프라인 실행
    await onAllowed();

    if (adResult.message != null && adResult.message!.isNotEmpty) {
      onMessage(adResult.message!);
    }
    return true;
  }
}
