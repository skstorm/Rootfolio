import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_constants.dart';
import 'di/injection_container.dart';
import 'di/di_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 추후 Firebase 초기화 등 비동기 작업 위치
  
  configureDependencies(DIConstants.dev); // 일단 dev(Mock) 환경으로 초기화
  
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
