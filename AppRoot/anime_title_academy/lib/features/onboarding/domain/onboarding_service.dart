abstract class OnboardingService {
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchCompleted();
  Future<bool> requestPermissions();
}
