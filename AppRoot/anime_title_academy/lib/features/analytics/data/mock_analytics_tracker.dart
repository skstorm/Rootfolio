import 'dart:developer';
import 'package:injectable/injectable.dart';
import '../domain/analytics_tracker.dart';

@LazySingleton(as: AnalyticsTracker, env: ['dev'])
class MockAnalyticsTracker implements AnalyticsTracker {
  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    log('[Analytics Event] $name : $parameters');
  }
}
