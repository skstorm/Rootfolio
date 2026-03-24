import 'dart:async';

import 'package:anime_title_academy/core/ads/ad_reward_result.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/core/constants/ad_unit_constants.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleRewardedAdService implements AdService {
  const GoogleRewardedAdService({
    required this.mode,
  });

  @override
  final RewardedAdMode mode;

  @override
  Future<AdRewardResult> showRewardedAd({
    required TitleGenerationModel model,
  }) async {
    final adUnitId = AdUnitConstants.resolveRewardedAdUnitId(mode);
    if (adUnitId == null) {
      return AdRewardResult(
        status: AdRewardStatus.unavailable,
        message: mode == RewardedAdMode.production
            ? '프로덕션 광고 단위 ID가 설정되지 않았습니다.'
            : '현재 플랫폼에서는 광고를 지원하지 않습니다.',
      );
    }

    final completer = Completer<AdRewardResult>();
    var earnedReward = false;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (completer.isCompleted) {
                return;
              }
              completer.complete(
                earnedReward
                    ? const AdRewardResult(
                        status: AdRewardStatus.rewarded,
                        message: '광고 시청이 완료되어 보상이 지급되었습니다.',
                      )
                    : const AdRewardResult(
                        status: AdRewardStatus.dismissed,
                        message: '광고 시청이 중단되어 보상이 지급되지 않았습니다.',
                      ),
              );
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (completer.isCompleted) {
                return;
              }
              completer.complete(
                AdRewardResult(
                  status: AdRewardStatus.unavailable,
                  message: '광고 표시 실패: ${error.message}',
                ),
              );
            },
          );

          try {
            ad.show(
              onUserEarnedReward: (_, rewardItem) {
                final amount = rewardItem.amount;
                if (amount >= 0) {
                  earnedReward = true;
                }
              },
            );
          } catch (error) {
            ad.dispose();
            if (completer.isCompleted) {
              return;
            }
            completer.complete(
              AdRewardResult(
                status: AdRewardStatus.unavailable,
                message: '광고 실행 실패: $error',
              ),
            );
          }
        },
        onAdFailedToLoad: (error) {
          if (completer.isCompleted) {
            return;
          }
          completer.complete(
            AdRewardResult(
              status: AdRewardStatus.unavailable,
              message: '광고 로드 실패: ${error.message}',
            ),
          );
        },
      ),
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 45));
    } on TimeoutException {
      return const AdRewardResult(
        status: AdRewardStatus.unavailable,
        message: '광고 응답 시간이 초과되었습니다.',
      );
    }
  }
}
