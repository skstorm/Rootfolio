import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppLogger {
  void debug(String message, {String name = 'App'}) {
    if (!kDebugMode) return;
    developer.log(message, name: name, level: 500);
  }

  void info(String message, {String name = 'App'}) {
    developer.log(message, name: name, level: 800);
  }

  void warn(String message, {String name = 'App'}) {
    developer.log(message, name: name, level: 900);
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'App',
  }) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
