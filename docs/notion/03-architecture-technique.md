# Architecture technique

> **Statut : socle V1 complet et validé** — analyse sans erreur, 25/25 tests verts, APK debug construit. Validation BLE et arrière-plan restant à faire sur appareils physiques.
> Date : 2026-10-21. Source fonctionnelle : `Messagerie_hors-ligne_document_de_reflexion.md`.

## 1. Style d'architecture retenu

**Feature-first + Clean Architecture pragmatique.**

- **Feature-first** : chaque fonctionnalité possède ses propres couches, ce qui limite les dépendances croisées et permet de livrer le MVP par tranches verticales.
- **Clean Architecture pragmatique** : le domaine ne dépend ni de Flutter, ni de Drift, ni du BLE. Les interfaces (repositories, transports) sont dans le domaine ; les implémentations sont dans `data/`.
- **Pas de sur-abstraction** : pas de `UseCase` pour chaque getter, pas de mapper inutile, pas de couche « datasource » quand le repository suffit.

```text
┌──────────────────────────────────────────────────────────────┐
│ │ Presentation — écrans, widgets, Riverpod Notifiers            │
│ │  dépend de Application + Domain                              │
├──────────────────────────────────────────────────────────────┤
│ │ Application — orchestration, use cases, MeshEngine            │
│ │  dépend du Domain uniquement (contrats)                      │
├──────────────────────────────────────────────────────────────┤
│ │ Domain — entités, value objects, politiques, contrats         │
│ │  zéro import Flutter / Drift / BLE                           │
├──────────────────────────────────────────────────────────────┤
│ │ Data — Drift, SecureStorage, crypto, BLE, transport simulé    │
│ │  implémente les contrats du Domain                           │
└──────────────────────────────────────────────────────────────┘
```

**Règle d'or.** Le transport ne connaît ni le chat, ni les alertes, ni l'UI : il transporte des octets. Le `MeshEngine` ne connaît ni Flutter, ni Drift : il dépend de contrats.

## 2. Gestion d'état

**Riverpod 3.4.3**, avec des providers **manuels** (pas de `riverpod_generator`) pour garder le graphe de dépendances explicite et auditable.

- `Notifier` / `AsyncNotifier` pour l'état mutable.
- `StreamProvider` pour les messages et l'état du mesh.
- `Provider` pour les dépendances (repositories, services, horloge, générateur d'IDs).
- `AsyncValue` pour les états chargement / erreur / données.
- Les widgets ne contiennent **aucune** logique de protocole, de chiffrement ou de persistance.
- Les erreurs métier sont des `AppException` typées ; l'UI affiche un message localisé, avec le détail métier lorsque celui-ci est sûr (jamais de contenu de message ni de clé).

Pas de `setState` pour l'état partagé. `setState` reste toléré pour des détails purement locaux (animation d'un champ, expansion d'une carte).

## 3. Navigation

**go_router 18.1.0** avec routes typées et deep links internes (notification d'alerte, ouverture d'un salon). Routes V1 :

```text
/                     → onboarding (redirigé vers /chat si terminé)
/chat                 → salon de quartier
/alerts               → liste des alertes
/alerts/:alertId      → détail d'une alerte
/mesh                 → état du maillage, pairs, file d'attente
/settings             → réglages
/diagnostics          → journaux, export, état des permissions
/about                → version, crédits, limites de la V1
```

Les quatre onglets (`/chat`, `/alerts`, `/mesh`, `/settings`) utilisent un `StatefulShellRoute.indexedStack` : chaque onglet conserve sa pile de navigation. Les écrans de détail s'ouvrent sur le navigateur racine.
## 4. Structure des dossiers

```text
lib/
├── main.dart                         # lance bootstrap() puis HafatraApp
├── app/
│   ├── app.dart                      # MaterialApp.router, thème, locale, AppRuntime
│   ├── app_router.dart               # go_router, shell à 4 onglets, garde d'onboarding
│   ├── app_runtime.dart              # démarrage du mesh, alertes, cycle de vie
│   ├── bootstrap.dart                # AppDependencies + init DB/logs/identité
│   ├── providers.dart                # DI Riverpod, sessions, réglages, chat, mesh
│   └── shell.dart                    # NavigationBar et destinations
├── core/
│   ├── background/foreground_service.dart
│   ├── constants/                    # app_constants.dart, mesh_constants.dart
│   ├── crypto/crypto_service.dart    # Ed25519, SHA-256, génération de graine
│   ├── database/                     # app_database.dart + .g.dart (drift_dev)
│   ├── design_system/                # app_colors.dart, app_spacing.dart, app_theme.dart
│   ├── errors/app_exception.dart     # AppException scellée + ErrorMapper
│   ├── l10n/l10n.dart                # extension context.l10n + repli Material/Cupertino
│   ├── logging/app_logger.dart       # logger + RotatingFileSink (1 archive)
│   ├── notifications/                # notification_service.dart
│   ├── permissions/                  # permission_service.dart
│   ├── platform/battery_info.dart
│   ├── utils/                        # byte_utils, clock, date_format, id_generator
│   └── widgets/app_widgets.dart
├── features/
│   ├── identity/                     # data: channel, identity, secret_store / domain
│   ├── onboarding/presentation/
│   ├── chat/                         # data / domain / presentation
│   ├── mesh/                         # data (codec, transports) / domain / application
│   ├── alerts/                       # data / domain / presentation
│   └── settings/                     # data / domain / presentation
└── l10n/
    ├── arb/app_fr.arb                # template de génération
    ├── arb/app_mg.arb                # malgache
    └── generated/                    # généré par flutter gen-l10n
```

```text
test/
├── support/test_dependencies.dart    # base mémoire, secret store en RAM, batterie fixe
├── core/crypto_service_test.dart     # dérivation, signature, tailles, SHA-256
├── features/mesh/mesh_packet_codec_test.dart
├── features/alerts/alert_verifier_test.dart
└── widget_test.dart                  # onboarding FR → MG → permissions
tool/
├── alert_tool.dart                   # init / sign / verify (hors APK)
└── demo_authority.json               # clé privée de démonstration, hors assets
assets/
├── trusted_authorities.json          # clés publiques de confiance
└── demo/demo_alert.json              # alerte signée de démonstration
```

## 5. Découpage des modules

| Module | V1 | Data | Domain | Presentation |
|:---|:---|:---|:---|:---|
| **Identity** | Oui | `flutter_secure_storage` pour la graine Ed25519 ; profil local dans Drift | `Identity`, `KeyPair`, `IdentityRepository`, génération au premier lancement | Onboarding, nom affiché, empreinte de clé, export de secours (V1.1) |
| **Chat** | Oui | DAO Drift, messages, accusés, receipts | `ChatMessage`, `MessageStatus`, `ChatRepository` | Salon, composer, bulles, badges de statut, liste des pairs |
| **Mesh** | Oui | BLE + transport simulé, codec binaire, outbox, `seen_packets` | `MeshPacket`, `MeshTransport`, `MeshEngine`, `DedupCache`, `RoutingPolicy`, `RelayPolicy` | État du relais, nombre de pairs, file d'attente, diagnostics |
| **Alerts** | Oui (démo) | Clés de confiance, alertes reçues | `SignedAlert`, vérification Ed25519, expiration, anti-rejeu | Bannière d'urgence, liste, détail, badge « vérifiée » |
| **Settings** | Oui | Drift + secure storage | Préférences typées | Langue, thème, relais, seuil batterie, permissions |
| **Diagnostics** | Oui | Fichiers de log rotatifs | `DiagnosticsRepository` | Export/copier les logs, état BLE/service/batterie |

## 6. Flux d'un message

### 6.1 Sortant

```text
UI (composer)
  → ChatController.send(text)
  → MeshEngine.sendChat(text)          # validation, signature, insertion locale
  → ChatRepository / MeshRepository    # message « queued » + outbox
  → UI observe le stream Drift (statut « En attente »)
  → MeshRuntime._pump()                # toutes les 3 s
  → MeshTransport.send(frame)
  → si accepté : outbox supprimée, statut « Envoyé au réseau »,
    onPacketTransmitted() émet un relayReceipt
```

### 6.2 Entrant

```text
BLE / simulé
  → frame bytes
  → MeshPacketCodec.decode()
  → vérification signature + taille + version + canal
  → DedupCache.check(messageId)
  → si nouveau : persistance + émission UI
  → RelayPolicy.decide(ttl, batterie, priorité, densité)
  → si relais : TTL - 1, jitter, renvoi à un sous-ensemble de pairs
  → accusé de réception / relay receipt
```
## 7. Orchestration applicative

- `AppDependencies` (`bootstrap.dart`) construit une seule fois la base, le logger, la crypto, les repositories, les services Android et l'état initial. Il est injecté par surcharge de `appDependenciesProvider`.
- `SessionController` charge l'identité, le salon et l'état d'onboarding. `routerProvider` redirige automatiquement vers `/chat` quand l'onboarding est terminé.
- `MeshController` possède le `MeshRuntime` : démarrage, arrêt, changement de transport (BLE réel ou simulé), mise à jour des réglages et rafraîchissement des compteurs.
- `ChatController` sérialise les envois (un seul message en vol) et remonte les erreurs typées à l'UI.
- `AppRuntime` démarre le mesh après l'onboarding, affiche une notification pour chaque alerte vérifiée, rafraîchit les permissions au retour au premier plan et relance le mesh s'il a été arrêté.
- `DemoCompanion` n'est actif qu'en mode simulation : il joue le rôle de pairs virtuels, signe leurs ACK/reçus et publie un message d'accueil si le salon est vide.

**Point d'attention.** L'UI et le service de premier plan ne doivent jamais créer deux moteurs BLE concurrents. En V1, `MeshRuntime` vit dans l'isolate principal ; le service de premier plan maintient le processus en vie et relaie, mais le single-writer complet (service propriétaire de la base) reste une évolution à valider en recette.

## 8. Dépendances

> Versions verrouillées dans `pubspec.lock` après résolution du 2026-10-20. Les contraintes du `pubspec.yaml` utilisent `^` pour les correctifs, mais l'APK se construit toujours avec le lockfile.

### Runtime

| Package | Version | Rôle | Justification |
|:---|:---|:---|:---|
| `flutter_riverpod` | 3.4.3 | État | Mature, testable, adapté aux flux asynchrones |
| `go_router` | 18.1.0 | Navigation | Routes déclaratives, shell à onglets, redirection |
| `drift` | 2.35.2 | Base locale | Typage, streams réactifs, migrations |
| `drift_flutter` | 0.3.1 | Ouverture SQLite | Native assets, Android/iOS |
| `path_provider` | 2.1.6 | Répertoires | Logs et base |
| `flutter_secure_storage` | 11.2.0 | Clé privée | Keystore Android |
| `cryptography_plus` | 3.0.0 | Ed25519 / SHA-256 | Maintenu, pur Dart, API claire |
| `uuid` | 4.6.0 | Identifiants | UUID v7 |
| `collection` | 1.19.1 | Utilitaires | Listes, égalité |
| `logging` | 1.3.0 | Logs | Sinks et niveaux |
| `intl` | 0.20.3 | i18n | Dates, pluriels |
| `permission_handler` | 12.0.1 | Permissions | BLE, notifications, batterie |
| `bluetooth_low_energy` | 6.2.1 | BLE | Central + peripheral |
| `flutter_foreground_task` | 11.0.3 | Service Android | Maintenu, Flutter récent |
| `battery_plus` | 7.1.2 | Batterie | Politique de relais |
| `flutter_local_notifications` | 22.3.2 | Notifications | Alertes et service |
| `package_info_plus` | 10.2.2 | Diagnostics | Version de l'app |
| `device_info_plus` | 13.3.0 | Diagnostics | Constructeur/modèle |
| `flutter_localizations` | SDK | Localisations | Material/Cupertino avec repli `mg` |

### Développement

| Package | Version | Rôle |
|:---|:---|:---|
| `build_runner` | 2.16.2 | Génération Drift |
| `drift_dev` | 2.35.1 | Générateur Drift |
| `very_good_analysis` | 11.0.0 | Lints stricts |
| `mocktail` | 1.0.5 | Mocks |
| `flutter_test` | SDK | Tests |
| `integration_test` | SDK | Tests d'intégration (harnais prêt, scénarios à ajouter) |

**Écartés après arbitrage :** `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation` et `riverpod_lint`/`custom_lint`. Les entités V1 sont peu nombreuses et écrites à la main ; les supprimer réduit le temps de génération, les dépendances transitives et les frictions de lints. Drift reste le seul générateur nécessaire.

**Non retenus :** `sqflite` (pas de streams réactifs), `sqlite3_flutter_libs` (EOL), `flutter_background_service` (moins récent), `flutter_blue_plus` (pas de rôle périphérique), `provider` (Riverpod couvre le besoin), `get_it` (Riverpod fait l'injection).

**Note `permission_handler`.** `permission_handler_android` 14.x déclare `compileSdk = 37`. Le SDK installé expose le dossier `platforms/android-37.0`, tandis qu'AGP 9.1 cherche `android-37` : le build échoue. La solution retenue est de pinner `permission_handler: 12.0.1` et `permission_handler_android: 13.0.1` (compileSdk 35) via `dependency_overrides`, en attendant un correctif amont. Cette épingle devra être retirée dès que possible.

## 9. Environnement de développement

| Élément | État constaté |
|:---|:---|
| Flutter | 3.47.5 stable, Dart 3.13.4 |
| Android SDK | SDK 36 installé ; `flutter doctor` signale encore des licences non acceptées. Le build debug a néanmoins réussi après installation de la plateforme 37.0 et épinglage de `permission_handler_android`. |
| Appareil Android | Aucun téléphone/émulateur connecté (`adb` absent du PATH) |
| Build Windows | Visual Studio absent ; le desktop Windows n'est pas une cible de validation |
| Chrome | Disponible, mais non représentatif du BLE et du service Android |
| Build Android | `flutter build apk --debug` réussi : `build/app/outputs/flutter-apk/app-debug.apk` |
| Dépôt | Dossier non versionné ; code, tests, CLI et assets présents |
| Analyse | `flutter analyze` : aucune erreur, aucun avertissement (2026-10-21) |
| Tests | `flutter test` : 25/25 verts |
