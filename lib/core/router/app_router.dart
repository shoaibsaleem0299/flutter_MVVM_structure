import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_coordinator.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/loading_indicator.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects only when the auth status changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen(
    authCoordinatorProvider.select((s) => s.status),
    (_, __) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authCoordinatorProvider).status;
      final loc = state.matchedLocation;
      switch (status) {
        case AuthStatus.unknown:
          return loc == Routes.splash ? null : Routes.splash;
        case AuthStatus.unauthenticated:
          return loc == Routes.login ? null : Routes.login;
        case AuthStatus.authenticated:
          return (loc == Routes.login || loc == Routes.splash)
              ? Routes.home
              : null;
      }
    },
    errorBuilder: (context, state) => AppScaffold(
      title: 'Page Not Found',
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('The requested page does not exist.'),
            const SizedBox(height: 24),
            AppButton(
              label: 'Go Home',
              onPressed: () => context.go(Routes.home),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const AppScaffold(body: LoadingIndicator()),
      ),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: Routes.home, builder: (_, __) => const HomePage()),
      GoRoute(path: Routes.settings, builder: (_, __) => const SettingsPage()),
    ],
  );
});
