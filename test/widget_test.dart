import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hafatra/app/app.dart';
import 'package:hafatra/app/providers.dart';

import 'support/test_dependencies.dart';

void main() {
  testWidgets('parcours d’accueil : validation, langue et mode démo', (
    tester,
  ) async {
    final harness = await createTestHarness();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await harness.dispose();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDependenciesProvider.overrideWithValue(harness.dependencies),
        ],
        child: const HafatraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur Hafatra'), findsOneWidget);
    expect(find.text('Étape 1 sur 3'), findsOneWidget);

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Qui êtes-vous ?'), findsOneWidget);
    expect(find.text('HAFATRA'), findsOneWidget);

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Entrez un nom affiché.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Rasoa');
    await tester.tap(find.text('Malgache'));
    await tester.pumpAndSettle();

    expect(find.text('Iza ianao?'), findsOneWidget);
    expect(find.text('Hanohy'), findsOneWidget);

    final demoTile = find.byType(SwitchListTile);
    await tester.ensureVisible(demoTile);
    await tester.pumpAndSettle();
    await tester.tap(demoTile);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(demoTile).value, isTrue);

    await tester.tap(find.text('Hanohy'));
    await tester.pumpAndSettle();

    expect(find.text("Mba hahafahan'ny hafatra mandeha"), findsOneWidget);
    expect(find.textContaining('simulation'), findsOneWidget);
  });
}
