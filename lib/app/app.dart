import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/app_router.dart';
import 'package:hafatra/app/app_runtime.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/design_system/app_theme.dart';
import 'package:hafatra/core/l10n/l10n.dart';

/// Racine de l'application : thème, langue et navigation.
final class HafatraApp extends ConsumerWidget {
  const HafatraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.theme.themeMode,
      locale: Locale(settings.localeCode),
      supportedLocales: supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        return AppRuntime(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
