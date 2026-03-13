import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/gallery/presentation/gallery_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/title_academy/presentation/home_page.dart';
import '../../features/title_academy/presentation/result_page.dart';

// 임시 플레이스홀더 화면 (각 모듈 작업 시 실제 화면으로 대체)
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Placeholder for $title')),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteNames.gallery,
      builder: (context, state) => const GalleryPage(),
    ),
    GoRoute(
      path: RouteNames.result,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ResultPage(
          imagePath: extra['imagePath'] as String?,
          style: extra['style'] as String? ?? 'anime',
        );
      },
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const WelcomePage(),
    ),
  ],
);
