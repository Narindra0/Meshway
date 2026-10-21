import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/app.dart';
import 'package:hafatra/app/bootstrap.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/design_system/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final dependencies = await bootstrap();
    FlutterError.onError = (details) {
      dependencies.logger.error(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      dependencies.logger.error(
        'Uncaught platform error',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
    runApp(
      ProviderScope(
        overrides: [appDependenciesProvider.overrideWithValue(dependencies)],
        child: const HafatraApp(),
      ),
    );
  } on Object catch (error, stackTrace) {
    debugPrint('Hafatra bootstrap failed: $error\n$stackTrace');
    runApp(BootstrapFailureApp(error: error));
  }
}

/// Écran de secours si la base, le Keystore ou les réglages sont illisibles.
final class BootstrapFailureApp extends StatelessWidget {
  const BootstrapFailureApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: AppTheme.light.colorScheme.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Hafatra n’a pas pu démarrer',
                    style: AppTheme.light.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Fermez l’application puis rouvrez-la. Si le problème '
                    'persiste, vérifiez l’espace de stockage du téléphone.',
                    style: AppTheme.light.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '$error',
                    style: AppTheme.light.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
