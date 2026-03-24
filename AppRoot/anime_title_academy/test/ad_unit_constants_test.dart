import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/constants/ad_unit_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdUnitConstants', () {
    test('returns test rewarded unit for android in test mode', () {
      final unitId = AdUnitConstants.resolveRewardedAdUnitId(
        RewardedAdMode.test,
        platformOverride: TargetPlatform.android,
        isWebOverride: false,
      );

      expect(unitId, 'ca-app-pub-3940256099942544/5224354917');
    });

    test('returns test rewarded unit for ios in test mode', () {
      final unitId = AdUnitConstants.resolveRewardedAdUnitId(
        RewardedAdMode.test,
        platformOverride: TargetPlatform.iOS,
        isWebOverride: false,
      );

      expect(unitId, 'ca-app-pub-3940256099942544/1712485313');
    });

    test('returns null for disabled mode', () {
      final unitId = AdUnitConstants.resolveRewardedAdUnitId(
        RewardedAdMode.disabled,
        platformOverride: TargetPlatform.android,
        isWebOverride: false,
      );

      expect(unitId, isNull);
    });

    test('returns null on web even in test mode', () {
      final unitId = AdUnitConstants.resolveRewardedAdUnitId(
        RewardedAdMode.test,
        platformOverride: TargetPlatform.android,
        isWebOverride: true,
      );

      expect(unitId, isNull);
    });
  });
}
