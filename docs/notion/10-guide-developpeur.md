# Guide du développeur

> **Ce guide s'adresse à une personne qui reprend le dépôt.** Il explique comment démarrer, où se trouve chaque chose, et quelles conventions sont appliquées. La page « Tests, qualité et déploiement » couvre les portes de qualité ; la page « Architecture technique » couvre le détail des couches.

## 1. Prérequis

| Outil | Version | Rôle |
|:---|:---|:---|
| Flutter | 3.47.5 | SDK, inclut l'exécutable `dart` |
| Dart | 3.13.4 | Langage, tests, formatage |
| Android SDK | compileSdk 36, targetSdk 36 | Build Android |
| Java / Kotlin | 17 | Gradle |

```bash
flutter pub get
flutter doctor
```

**Point d'attention** : `flutter doctor --android-licenses` signale encore des licences Android non acceptées. Le build **debug** fonctionne malgré cela ; le build **release** est bloqué tant qu'elles ne sont pas acceptées.

## 2. Démarrage

```bash
flutter pub get          # installe les dépendances
flutter run              # lance sur l'appareil ou l'émulateur choisi
flutter test             # 25 tests
flutter build apk --debug # APK debug
```

L'APK sort dans `build/app/outputs/flutter-apk/app-debug.apk`.

Au premier lancement, l'onboarding demande un nom affiché, un quartier, la langue, puis propose le **mode démo**. Le mode démo remplace le BLE par un transport simulé à trois pairs, simule des accusés de réception et embarque une alerte signée — sans demander aucune permission Bluetooth. C'est le moyen le plus rapide de voir le produit fonctionner seul.

## 3. Arborescence

| Chemin | Contenu |
|:---|:---|
| `lib/main.dart` | Point d'entrée, capture des erreurs globales, écran de secours |
| `lib/app/` | `bootstrap`, `providers`, `app_router`, `app`, `shell`, `app_runtime` |
| `lib/core/` | Socle transverse : crypto, base, logs, permissions, design system, erreurs, notifications, arrière-plan |
| `lib/features/` | `chat`, `alerts`, `mesh`, `identity`, `onboarding`, `settings` |
| `lib/l10n/` | Fichiers ARB et localisations générées |
| `test/` | Tests unitaires, widget et harnais |
| `tool/alert_tool.dart` | CLI de signature et de vérification des alertes |
| `assets/` | Autorités de confiance et alerte de démonstration |

### Convention de dossiers par feature

Chaque feature suit la même coupe :

- `data/` — implémentations, accès base de données, codecs ;
- `domain/` — entités et règles métier, sans dépendance Flutter ;
- `presentation/` — écrans et widgets ;
- `application/` — orchestrations (uniquement dans `mesh`).

`lib/core/` suit le même esprit : un dossier par domaine transverse (`crypto`, `database`, `logging`, `errors`, `design_system`, `permissions`, `notifications`, `background`, `platform`, `utils`, `widgets`, `constants`).

## 4. Le flux de démarrage

`main()` appelle `bootstrap()`, qui construit **une seule fois** toutes les dépendances lourdes :

1. ouverture du fichier de logs rotatif (facultatif — l'application continue sans) ;
2. création du logger ;
3. ouverture de la base Drift et vérification par `SELECT 1` ;
4. chargement de l'identité, du quartier et des réglages ;
5. construction du moteur de maillage, du service d'alertes et du service de premier plan.

Si une étape critique échoue, `main()` affiche `BootstrapFailureApp` : un écran de secours explicite plutôt qu'un écran blanc. Les dépendances sont ensuite injectées dans `ProviderScope` via `appDependenciesProvider.overrideWithValue`.

**Règle** : rien ne doit être instancié deux fois. Les providers Riverpod lisent tous `appDependenciesProvider`.

## 5. Conventions de code

- Analyse statique avec `very_good_analysis`, plus `strict-casts`, `strict-inference` et `strict-raw-types`.
- Aucun `print` en production : uniquement `AppLogger`.
- Les exceptions métier héritent de `AppException` (`lib/core/errors/app_exception.dart`) et sont traduites en messages utilisateur via les libellés `errorStorage`, `errorCrypto`, `errorTransport`, `errorPermission`, `errorValidation`.
- Les libellés passent par `AppLocalizations` ; aucun texte en dur dans les écrans.
- Pour l'interface, le style vient de `AppTheme` et `AppColors` ; pas de couleur littérale dans un widget.
- Les entités de base sont des classes Drift ; les accès passent par des repositories.
- Les générés (`*.g.dart`, `*.freezed.dart`) ne sont jamais modifiés à la main.

## 6. Internationalisation

Les fichiers source sont `lib/l10n/arb/app_fr.arb` et `app_mg.arb`. Les fichiers `lib/l10n/generated/` sont produits par `flutter gen-l10n` et versionnés pour que le dépôt se compile sans étape de génération.

```bash
flutter gen-l10n
```

Après ajout d'une clé : mettre à jour **les deux** fichiers ARB, régénérer, puis vérifier que l'interface ne mélange pas français et malgache.

## 7. Ajouter un transport

Le cœur ne connaît aucun transport. Pour en ajouter un :

1. implémenter `MeshTransport` (`lib/features/mesh/domain/mesh_transport.dart`) ;
2. écrire le transport dans `lib/features/mesh/data/transports/`, comme `SimulatedTransport` ou `BleMeshTransport` ;
3. le choisir dans `MeshController.start()` (`lib/app/providers.dart`), où le mode démo décide déjà entre les deux ;
4. brancher un codec de fragment si le transport est fragmenté, comme `BleChunkCodec` ;
5. ne toucher à `MeshEngine` que si la sémantique de relais change.

C'est ce contrat qui rend Wi-Fi Direct, son, QR, NFC ou LoRa ajoutables sans refonte.

## 8. CLI des alertes

```bash
# Vérifier l'alerte livrée
dart run tool/alert_tool.dart verify \
  --alert assets/demo/demo_alert.json \
  --authorities assets/trusted_authorities.json

# Générer une autorité de démonstration (hors APK)
dart run tool/alert_tool.dart init \
  --out tool/demo_authority.json \
  --authorities assets/trusted_authorities.json

# Signer une alerte
dart run tool/alert_tool.dart sign \
  --key tool/demo_authority.json \
  --out assets/demo/demo_alert.json \
  --severity warning \
  --title "Titre" --body "Message" --area "Quartier"
```

**Avertissement** : `tool/demo_authority.json` contient une clé privée de démonstration. Elle ne doit **jamais** être embarquée dans l'APK ni servir à une alerte réelle.

## 9. Dépannage

| Symptôme | Cause probable | Action |
|:---|:---|:---|
| `flutter pub get` échoue sur le SDK | `environment.sdk` de `pubspec.yaml` ne correspond pas au Dart installé | Vérifier la version de Dart (`dart --version`) et l'ajuster |
| Build release refusé | Licences Android non acceptées | `flutter doctor --android-licenses` |
| Le scan BLE ne trouve rien | Permissions non accordées, ou `neverForLocation` mal configuré | Rejouer l'onboarding, vérifier les logs de `PermissionService` |
| L'application est tuée en arrière-plan | Optimisation de batterie active | Réglages → Permissions → Optimisation de batterie → « Ne pas restreindre » |
| L'écran « Hafatra n'a pas pu démarrer » | Base, Keystore ou réglages illisibles | Relancer l'application ; si l'erreur persiste, vérifier l'espace de stockage |
| `flutter analyze` signale des `.g.dart` | Fichiers générés absents | `flutter pub run build_runner build --delete-conflicting-outputs` |

## 10. Reconstruire proprement

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Si `flutter analyze` signale des erreurs de version de SDK, vérifier `pubspec.yaml` (`environment.sdk`) avant toute autre action.
