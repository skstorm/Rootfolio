enum RewardedAdMode {
  disabled,
  fake,
  test,
  production,
}

extension RewardedAdModeX on RewardedAdMode {
  static RewardedAdMode resolve(
    String overrideValue, {
    required bool isDebugBuild,
    required bool bypassQuotaAndAds,
  }) {
    switch (overrideValue.trim().toLowerCase()) {
      case 'disabled':
        return RewardedAdMode.disabled;
      case 'fake':
      case 'mock':
        return RewardedAdMode.fake;
      case 'test':
      case 'debugtest':
        return RewardedAdMode.test;
      case 'production':
      case 'prod':
        return RewardedAdMode.production;
      case 'auto':
      case '':
        if (bypassQuotaAndAds) {
          return RewardedAdMode.disabled;
        }
        return isDebugBuild ? RewardedAdMode.test : RewardedAdMode.production;
      default:
        if (bypassQuotaAndAds) {
          return RewardedAdMode.disabled;
        }
        return isDebugBuild ? RewardedAdMode.test : RewardedAdMode.production;
    }
  }

  String get debugLabel {
    switch (this) {
      case RewardedAdMode.disabled:
        return '광고 비활성화';
      case RewardedAdMode.fake:
        return '가짜 광고 모드';
      case RewardedAdMode.test:
        return '테스트 광고 모드';
      case RewardedAdMode.production:
        return '프로덕션 광고 모드';
    }
  }
}
