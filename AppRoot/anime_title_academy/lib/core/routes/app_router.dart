import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/gallery/presentation/gallery_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/title_academy/presentation/home_page.dart';
import '../../features/title_academy/presentation/result_page.dart';
import '../../features/title_academy/presentation/prompt_sandbox_page.dart';

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
    GoRoute(
      path: RouteNames.promptSandbox,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PromptSandboxPage(
          imagePath: extra['imagePath'] as String?,
        );
      },
    ),
  ],
);
