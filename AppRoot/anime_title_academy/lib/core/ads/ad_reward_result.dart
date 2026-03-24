enum AdRewardStatus {
  rewarded,
  dismissed,
  unavailable,
}

class AdRewardResult {
  const AdRewardResult({
    required this.status,
    this.message,
  });

  final AdRewardStatus status;
  final String? message;

  bool get isRewarded => status == AdRewardStatus.rewarded;
}
