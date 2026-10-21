import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/app/shell.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/features/alerts/presentation/alert_detail_screen.dart';
import 'package:hafatra/features/alerts/presentation/alerts_screen.dart';
import 'package:hafatra/features/chat/presentation/chat_screen.dart';
import 'package:hafatra/features/mesh/presentation/mesh_screen.dart';
import 'package:hafatra/features/onboarding/presentation/onboarding_screen.dart';
import 'package:hafatra/features/settings/presentation/about_screen.dart';
import 'package:hafatra/features/settings/presentation/diagnostics_screen.dart';
import 'package:hafatra/features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _chatNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'chat',
);
final GlobalKey<NavigatorState> _alertsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'alerts',
);
final GlobalKey<NavigatorState> _meshNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'mesh',
);
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ValueNotifier<bool>(
    ref.read(sessionControllerProvider).onboardingComplete,
  );
  ref.listen<bool>(
    sessionControllerProvider.select((state) => state.onboardingComplete),
    (previous, next) => onboardingComplete.value = next,
  );
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingComplete.value ? '/chat' : '/',
    refreshListenable: onboardingComplete,
    redirect: (context, state) {
      final complete = onboardingComplete.value;
      final atOnboarding = state.matchedLocation == '/';
      if (!complete && !atOnboarding) {
        return '/';
      }
      if (complete && atOnboarding) {
        return '/chat';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _alertsNavigatorKey,
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _meshNavigatorKey,
            routes: [
              GoRoute(
                path: '/mesh',
                builder: (context, state) => const MeshScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/alerts/:alertId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            AlertDetailScreen(alertId: state.pathParameters['alertId']!),
      ),
      GoRoute(
        path: '/diagnostics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: Text(context.l10n.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.l10n.errorGeneric, textAlign: TextAlign.center),
        ),
      ),
    ),
  );
  ref.onDispose(() {
    router.dispose();
    onboardingComplete.dispose();
  });
  return router;
});
