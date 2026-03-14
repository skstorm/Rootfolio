import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_constants.dart';
import 'di/injection_container.dart';
import 'di/di_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경변수 로드
  await dotenv.load(fileName: ".env");
  
  configureDependencies(DIConstants.prod); // AI 연동을 위해 prod 환경으로 변경
  
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
