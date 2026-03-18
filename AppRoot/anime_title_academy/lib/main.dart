import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/ui_constants.dart';
import 'di/injection_container.dart';
import 'di/di_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // PC 해상도 고정 (Windows 전용)
  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(UiConstants.pcWindowWidth, UiConstants.pcWindowHeight),
      minimumSize: Size(UiConstants.pcWindowWidth, UiConstants.pcWindowHeight),
      maximumSize: Size(UiConstants.pcWindowWidth, UiConstants.pcWindowHeight),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setResizable(false); // E2E 대응을 위해 리사이즈 금지
    });
  }

  // 환경변수 로드
  await dotenv.load(fileName: ".env");
  
  await configureDependencies(DIConstants.prod);
  getIt<AppConfig>().validate();
  
  runApp(
    const ProviderScope(
      child: AnimeTitleAcademyApp(),
    ),
  );
}

class AnimeTitleAcademyApp extends StatelessWidget {
  const AnimeTitleAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // 다크 테마 강제
      routerConfig: appRouter,
    );
  }
}
