abstract class AnalyticsTracker {
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
}
