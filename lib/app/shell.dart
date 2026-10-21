import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/l10n/l10n.dart';

/// Coquille à quatre onglets : salon, alertes, maillage, réglages.
final class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaces;
    final alertCount = ref.watch(alertsProvider).value?.length ?? 0;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: surfaces.card,
          boxShadow: [
            BoxShadow(
              color: surfaces.shadow,
              blurRadius: 22,
              offset: const Offset(0, -4),
            ),
            BoxShadow(color: surfaces.hairline, offset: const Offset(0, -0.7)),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 70,
          indicatorColor: scheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: const Icon(Icons.chat_bubble_rounded),
              label: l10n.navChat,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: alertCount > 0,
                backgroundColor: scheme.tertiary,
                textColor: scheme.onTertiary,
                label: Text('$alertCount'),
                child: const Icon(Icons.campaign_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: alertCount > 0,
                backgroundColor: scheme.tertiary,
                textColor: scheme.onTertiary,
                label: Text('$alertCount'),
                child: const Icon(Icons.campaign_rounded),
              ),
              label: l10n.navAlerts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.hub_outlined),
              selectedIcon: const Icon(Icons.hub_rounded),
              label: l10n.navMesh,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
