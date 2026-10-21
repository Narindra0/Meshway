# Tests, qualité et déploiement

> **Statut : automatisé au vert, terrain non fait.** 25/25 tests passent, l'analyse statique est propre, l'APK debug se construit. Rien n'a encore été validé sur un téléphone physique.

## 1. Portes qualité

```bash
dart format --set-exit-if-changed lib test tool
flutter analyze                 # objectif : 0 erreur, 0 info
flutter test
flutter build apk --debug
```

**État au 2026-10-21** : le formatage ne change rien, `flutter analyze` renvoie « No issues found! », `flutter test` passe **25/25**, et `flutter build apk --debug` produit `build/app/outputs/flutter-apk/app-debug.apk`.

Gradle émet un avertissement de migration Kotlin pour `bluetooth_low_energy_android` : il n'est pas bloquant, mais devra être suivi.

## 2. Tests automatisés

| Fichier | Couverture | Nombre |
|:---|:---|:---:|
| `test/core/crypto_service_test.dart` | Dérivation déterministe, signature/vérification, altérations, SHA-256, tailles invalides | 7 |
| `test/features/mesh/mesh_packet_codec_test.dart` | Aller-retour, altération payload/expéditeur, signature, TTL/sauts, magic/version/longueur, UUID invalide | 11 |
| `test/features/alerts/alert_verifier_test.dart` | Alerte valide, autorité inconnue, expirée, future, hors période, signature/contenu altérés, JSON invalide, alerte embarquée | 6 |
| `test/widget_test.dart` | Onboarding FR → validation du nom → profil → bascule malgache → mode démo → permissions | 1 |
| **Total** | `flutter test` | **25 verts** |

### Le harnais

`test/support/test_dependencies.dart` fournit :

- une base Drift **en mémoire** ;
- un `InMemorySecretStore` ;
- une source de batterie statique ;
- un logger silencieux.

**Aucun test ne touche au Keystore, au BLE réel, aux fichiers de logs ni au réseau.** C'est ce qui permet d'exécuter la suite sur n'importe quelle machine, sans matériel.

## 3. Ce qui n'est pas couvert

| Domaine | Pourquoi | Statut |
|:---|:---|:---|
| **Transport BLE réel** | Dépend du matériel, des permissions runtime et du service Android | **Recette terrain** |
| **Intégration multi-nœuds** (3 à 5 nœuds, propagation, doublons, coupure) | Le transport simulé n'est couvert qu'indirectement via le codec | À écrire |
| **Migration Drift depuis une version antérieure** | `schemaVersion = 1` : il n'existe pas encore de version antérieure | À ajouter à la première évolution |
| **Widgets chat, alertes, réglages, diagnostics** | Seul l'onboarding a un test d'interface | À écrire |
| **Golden tests** | Aucun golden n'est versionné | Décision à arbitrer |

### Pourquoi pas de golden pour l'instant

Le rendu visuel du redesign a été contrôlé avec un harnais temporaire — 14 captures clair/sombre, tous les écrans — puis supprimé. Un golden stable demanderait de charger `Inter` et `MaterialIcons` via `dart:ui loadFontFromList` (les tests tournent sinon avec la police de test), d'immobiliser `LiveDot` et de figer l'horloge. Or les libellés de date produits par un `FixedClock` exécutent aussi des égalités d'horodatage partagées par UUID : l'ordre de deux messages proches devient aléatoire. À reprendre en test dédié si l'on veut un verrou visuel durable.

## 4. Règles de code

- Couverture cible : **≥ 80 %** sur `domain/` et `mesh/` (codec, crypto, politiques). **La couverture n'est pas encore mesurée** : lancer `flutter test --coverage`, puis `genhtml` ou le rapport de l'IDE.
- Aucun `print` en production ; `AppLogger` uniquement.
- Aucun `dynamic` non justifié ; `strict-casts`, `strict-inference`, `strict-raw-types`.
- Analyse statique avec `very_good_analysis`. Les rares exceptions (`document_ignores`, `specify_nonobvious_property_types`, `omit_local_variable_types`) sont commentées dans le code.
## 5. Outil d'alertes en ligne de commande

`tool/alert_tool.dart` fonctionne hors application. Il lit et écrit du JSON, sans jamais toucher au BLE ni à l'interface.

```bash
dart run tool/alert_tool.dart init \
  --out tool/demo_authority.json \
  --authorities assets/trusted_authorities.json \
  --id demo-authority --name "Autorité de démonstration"

dart run tool/alert_tool.dart sign \
  --key tool/demo_authority.json \
  --out assets/demo/demo_alert.json \
  --alert-id alert-001 --severity warning \
  --title "Eau coupée" --body "Coupure prévue ce soir." \
  --area "Analakely"

dart run tool/alert_tool.dart verify \
  --alert assets/demo/demo_alert.json \
  --authorities assets/trusted_authorities.json
```

**Règle absolue.** La clé privée ne doit jamais être placée dans `assets/` ni dans l'APK. `tool/demo_authority.json` est hors du bundle Android.

## 6. Recette terrain minimale

C'est le contrôle manuel qui manque aujourd'hui. Huit scénarios, dans cet ordre :

1. **2 téléphones** : envoi, accusé, statut.
2. **3 téléphones** : relais par un intermédiaire, TTL.
3. **5+ téléphones** : doublons, ordre, batterie.
4. **Marques** : Tecno, Infinix, Xiaomi, Samsung (si disponibles).
5. **Écran éteint**, application en arrière-plan, service tué par le constructeur.
6. **Mode avion**, Bluetooth coupé, redémarrage du téléphone.
7. **Alertes** : alerte signée valide, alerte falsifiée, alerte expirée.
8. **Batterie** : une heure de relais actif, mesure de la consommation.

## 7. Configuration Android

### `build.gradle.kts`

| Paramètre | Valeur |
|:---|:---|
| `namespace` / `applicationId` | `mg.hafatra` |
| `compileSdk` / `targetSdk` | 36 |
| `minSdk` | 24 (Android 7.0) |
| Java / Kotlin | 17 |
| Désugar JDK | activé (`desugar_jdk_libs 2.1.5`) |
| Minification | **désactivée** (`isMinifyEnabled = false`) |
| Signature release | **celle de debug** — à remplacer avant publication |

### Permissions déclarées

| Permission | Cible | Rôle |
|:---|:---|:---|
| `BLUETOOTH`, `BLUETOOTH_ADMIN` | `maxSdkVersion 30` | Bluetooth classique, Android 11 et antérieurs |
| `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | `maxSdkVersion 30` | Requis par le scan BLE sur ces versions |
| `BLUETOOTH_SCAN` | Android 12+ | Balayage, avec `neverForLocation` |
| `BLUETOOTH_ADVERTISE` | Android 12+ | Diffusion du service |
| `BLUETOOTH_CONNECT` | Android 12+ | Connexion aux pairs |
| `FOREGROUND_SERVICE` | — | Service de premier plan |
| `FOREGROUND_SERVICE_CONNECTED_DEVICE` | Android 14+ | Type de service `connectedDevice` |
| `POST_NOTIFICATIONS` | Android 13+ | Notifications d'alerte |
| `RECEIVE_BOOT_COMPLETED` | — | Redémarrage du relais au boot |
| `WAKE_LOCK`, `VIBRATE` | — | Maintien en activité, alerte vibrante |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | — | Exclusion de l'optimisation batterie |

**`uses-feature android.hardware.bluetooth_le` avec `required="false"`** : l'application doit pouvoir tourner en mode démonstration sur un appareil sans BLE.

**Application** : `allowBackup="false"`, `fullBackupContent="false"` (la base locale ne doit pas partir dans une sauvegarde cloud), `usesCleartextTraffic="false"`.

### Service de premier plan

| Paramètre | Valeur |
|:---|:---|
| Canal de notification | `hafatra_service` — « Relais Hafatra », importance **LOW**, priorité **LOW** |
| Type de service | `connectedDevice` |
| Icône de notification | `@drawable/ic_stat_hafatra` |
| Redémarrage automatique | `allowAutoRestart: true` |
| Arrêt avec la tâche | `stopWithTask: false` |
| Route de notification | `/chat` |

## 8. Avant une publication

| Étape | État |
|:---|:---|
| `flutter doctor --android-licenses` | **À faire** — licences restantes non acceptées |
| Signature release réelle | **À faire** — la configuration de debug est encore utilisée |
| Minification et réduction de ressources | **À faire** — désactivées pour l'instant |
| `split-per-ABI` | À faire pour réduire le poids de l'APK |
| Identifiant Play Store | `mg.hafatra` est un identifiant de prototype, modifiable |
| Icône launcher | **Reste celle de Flutter** |
| Clé d'autorité de production | Aucune : seule la clé de démonstration est active |
| Documentation Play sur les restrictions de service de premier plan | À écrire |

## 9. Ce que la V1 ne fait pas

- Le salon public n'est **pas** chiffré de bout en bout.
- Messages privés, QR, son, Wi-Fi Direct, NFC, USB, LoRa et passerelles ne sont **pas** implémentés.
- Le statut « Livré » est **réservé à la V2**.
- Aucune clé de production : l'autorité de démonstration est explicitement non officielle.
