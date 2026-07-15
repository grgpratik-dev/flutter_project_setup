import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_setup/src/app/router/app_route.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static final GoRouter goRouter = GoRouter(
    debugLogDiagnostics: kDebugMode,
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.onboarding.path,
    routes: [
      // Define your app routes here
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}
