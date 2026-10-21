# Hafatra — Architecture technique

> **Statut : socle V1 complet et validé** — analyse sans erreur, 25/25 tests verts,
> APK debug construit. Validation BLE et arrière-plan restant à faire sur appareils physiques.**
> Date : 2026-10-21
> Source fonctionnelle : `Messagerie_hors-ligne_document_de_reflexion.md`
> Recherche dépendances : pub.dev, consultée le 2026-10-20.
> Dernière mise à jour : UI, routeur, CLI d'alertes, assets de démonstration et tests.

---

## 1. Décisions validées

Le document de réflexion décrit une vision complète (V1 → V3). Les arbitrages suivants ont été validés
avec le porteur du projet avant l'écriture du code.

| ID | Sujet | Décision validée | Conséquence |
|:---|:---|:---|:---|
| **D1** | Périmètre | **Architecture multi-transport**, avec **BLE réel + transport simulé fonctionnels**. Les autres transports (Wi-Fi Direct, son, QR, NFC, USB, LoRa, passerelles) sont des contrats et des emplacements prévus, **pas des fonctionnalités livrées**. | Le cœur ne dépend d'aucun transport ; ajouter un transport ne demande pas de refonte. |
| **D2** | Transport Bluetooth | Vraie implémentation BLE (central + périphérique) derrière `MeshTransport`, plus un transport simulé pour les tests. Service de premier plan Android. | Le BLE devra être validé sur les deux téléphones du porteur ; le transport simulé couvre les tests automatisés. |
| **D3** | Alertes signées | Clé d'autorité de démonstration + liste de clés publiques de confiance importable + outil CLI de signature hors APK. **Aucune clé de production** sans partenaire. | Le parcours complet est testable ; la gouvernance réelle reste à signer avec une autorité. |
| **D4** | Nom et langue | Nom **Hafatra**, interface en **français par défaut**, malgache disponible via le sélecteur et les réglages. | Les ARB français et malgache sont livrés dès la V1. |
| **D5** | « Je suis en sécurité » | **Reporté en V2**, après les messages privés chiffrés. | Pas de diffusion publique de l'état des personnes en V1. |
| **D6** | Cible matérielle | Android 7.0+ (`minSdk 24`), téléphones d'entrée de gamme, APK par ABI. iOS hors périmètre. | Le service Android et le BLE sont les cibles de validation. |
| **D7** | Public pilote | **Quartier dense** (marché, université, quartier), 15 à 30 téléphones proches. | L'UX privilégie le salon public, la proximité et la clarté du statut. |

> **Périmètre exact de cette itération :** le cœur multi-transport, le salon de quartier public, le
> flooding TTL + déduplication, le statut honnête, le BLE réel, le transport simulé, les alertes signées
> de démonstration et l'assistant d'arrière-plan. Les messages privés, le QR, le son, le Wi-Fi Direct,
> le NFC, l'USB, le LoRa et les passerelles ne sont **pas** implémentés ; leurs interfaces sont prévues.

---

## 2. Contraintes et état de l'environnement

| Élément | État constaté |
|:---|:---|
| Flutter | 3.47.5 stable, Dart 3.13.4 |
| Android SDK | SDK 36 installé ; `flutter doctor` signale encore des licences non acceptées. Le build debug a néanmoins réussi après installation de la plateforme 37.0 et épinglage de `permission_handler_android`. |
| Appareil Android | Aucun téléphone/émulateur connecté (`adb` absent du PATH) |
| Build Windows | Visual Studio absent ; le desktop Windows n'est pas une cible de validation |
| Chrome | Disponible, mais non représentatif du BLE et du service Android |
| Build Android | `flutter build apk --debug` **réussi** : `build/app/outputs/flutter-apk/app-debug.apk` |
| Dépôt | Dossier non versionné ; code, tests, CLI et assets présents |
| Analyse | `flutter analyze` : aucune erreur, aucun avertissement (2026-10-21) |
| Tests | `flutter test` : 25/25 verts |

**Conséquence :** le code est analysé, testé unitairement et compilé en APK debug. **Le BLE réel, le
service d'arrière-plan et la consommation batterie devront être validés sur au moins deux téléphones
Android physiques.** Cette limite doit être explicite dans le plan de recette.

---

## 3. Choix d'architecture

### 3.1 Style retenu

**Feature-first + Clean Architecture pragmatique.**

- **Feature-first** : chaque fonctionnalité possède ses propres couches, ce qui limite les dépendances
  croisées et permet de livrer le MVP par tranches verticales.
- **Clean Architecture pragmatique** : le domaine ne dépend ni de Flutter, ni de Drift, ni du BLE.
  Les interfaces (repositories, transports) sont dans le domaine ; les implémentations sont dans `data/`.
- **Pas de sur-abstraction** : pas de `UseCase` pour chaque getter, pas de mapper inutile, pas de
  couche « datasource » quand le repository suffit.

```text
┌──────────────────────────────────────────────────────────────┐
│ Presentation — écrans, widgets, Riverpod Notifiers            │
│  dépend de Application + Domain                              │
├──────────────────────────────────────────────────────────────┤
│ Application — orchestration, use cases, MeshEngine            │
│  dépend du Domain uniquement (contrats)                      │
├──────────────────────────────────────────────────────────────┤
│ Domain — entités, value objects, politiques, contrats         │
│  zéro import Flutter / Drift / BLE                           │
├──────────────────────────────────────────────────────────────┤
│ Data — Drift, SecureStorage, crypto, BLE, transport simulé    │
│  implémente les contrats du Domain                           │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Gestion d'état

**Riverpod 3.4.3**, avec des providers **manuels** (pas de génération `riverpod_generator`) pour garder
le graphe de dépendances explicite et auditable.

- `Notifier` / `AsyncNotifier` pour l'état mutable.
- `StreamProvider` pour les messages et l'état du mesh.
- `Provider` pour les dépendances (repositories, services, horloge, générateur d'IDs).
- `AsyncValue` pour les états chargement / erreur / données.
- Les widgets ne contiennent **aucune** logique de protocole, de chiffrement ou de persistance.
- Les erreurs métier sont des `AppException` typées ; l'UI affiche un message localisé, avec le détail
  métier lorsque celui-ci est sûr (jamais de contenu de message ni de clé).

Pas de `setState` pour l'état partagé. `setState` reste toléré pour des détails purement locaux
(animation d'un champ, expansion d'une carte).

### 3.3 Navigation

**go_router 18.1.0** avec routes typées et deep links internes (notification d'alerte, ouverture d'un
salon). Les routes V1 :

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

Les quatre onglets (`/chat`, `/alerts`, `/mesh`, `/settings`) utilisent un
`StatefulShellRoute.indexedStack` : chaque onglet conserve sa pile de navigation. Les écrans de détail
(`/alerts/:id`, `/diagnostics`, `/about`) s'ouvrent sur le navigateur racine. Le routeur observe
`SessionController.onboardingComplete` via un `ValueNotifier` et redirige automatiquement.

---

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
│   ├── background/
│   │   └── foreground_service.dart   # flutter_foreground_task + HafatraTaskHandler
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── mesh_constants.dart
│   ├── crypto/
│   │   └── crypto_service.dart       # Ed25519, SHA-256, génération de graine
│   ├── database/
│   │   ├── app_database.dart         # tables, requêtes, migrations
│   │   └── app_database.g.dart       # généré par drift_dev
│   ├── design_system/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   └── app_theme.dart
│   ├── errors/
│   │   └── app_exception.dart        # AppException scellée + ErrorMapper
│   ├── l10n/
│   │   └── l10n.dart                 # extension context.l10n + repli Material/Cupertino
│   ├── logging/
│   │   └── app_logger.dart           # logger + RotatingFileSink (1 archive)
│   ├── notifications/
│   │   └── notification_service.dart # canal « alertes » + icône dédiée
│   ├── permissions/
│   │   └── permission_service.dart   # BLE, notifications, batterie
│   ├── platform/
│   │   └── battery_info.dart         # BatteryInfoSource + implémentation battery_plus
│   ├── utils/
│   │   ├── byte_utils.dart
│   │   ├── clock.dart
│   │   ├── date_format.dart
│   │   └── id_generator.dart         # UUID v7
│   └── widgets/
│       └── app_widgets.dart          # composants partagés (cartes, états vides, erreurs)
├── features/
│   ├── identity/
│   │   ├── data/
│   │   │   ├── channel_service.dart
│   │   │   ├── identity_service.dart
│   │   │   └── secret_store.dart     # flutter_secure_storage
│   │   └── domain/
│   │       ├── channel_info.dart
│   │       └── local_identity.dart
│   ├── onboarding/
│   │   └── presentation/onboarding_screen.dart
│   ├── chat/
│   │   ├── data/chat_repository.dart # Drift + stream réactif
│   │   ├── domain/chat_message.dart  # ChatMessage, MessageStatus
│   │   └── presentation/chat_screen.dart
│   ├── mesh/
│   │   ├── data/
│   │   │   ├── codec/
│   │   │   │   ├── mesh_packet_codec.dart
│   │   │   │   └── payload_codecs.dart
│   │   │   ├── transports/
│   │   │   │   ├── ble_chunk_codec.dart
│   │   │   │   ├── ble_mesh_transport.dart
│   │   │   │   └── simulated_transport.dart
│   │   │   └── mesh_repository.dart  # outbox, seen_packets, receipts, purge
│   │   ├── domain/
│   │   │   ├── mesh_packet.dart
│   │   │   ├── mesh_transport.dart
│   │   │   ├── outbox_packet.dart
│   │   │   ├── rate_limiter.dart
│   │   │   └── relay_policy.dart
│   │   ├── application/
│   │   │   ├── demo_companion.dart   # pairs virtuels pour la démo
│   │   │   ├── mesh_engine.dart      # receive → vérifier → persister → relayer
│   │   │   └── mesh_runtime.dart     # transport, outbox, batterie, compteurs
│   │   └── presentation/mesh_screen.dart
│   ├── alerts/
│   │   ├── data/
│   │   │   ├── alert_service.dart
│   │   │   └── trusted_authority_source.dart
│   │   ├── domain/
│   │   │   ├── alert_verifier.dart
│   │   │   ├── signed_alert.dart
│   │   │   └── trusted_authority.dart
│   │   └── presentation/
│   │       ├── alert_detail_screen.dart
│   │       ├── alert_ui.dart
│   │       └── alerts_screen.dart
│   ├── settings/
│   │   ├── data/settings_repository.dart
│   │   ├── domain/app_settings.dart
│   │   └── presentation/
│   │       ├── about_screen.dart
│   │       ├── diagnostics_screen.dart
│   │       └── settings_screen.dart
│   └── ...                           # extensions futures : private_chat, safety, etc.
├── shared/                           # réservé aux extensions transverses (vide en V1)
└── l10n/
    ├── arb/
    │   ├── app_fr.arb                # template de génération
    │   └── app_mg.arb                # malgache
    └── generated/                    # généré par flutter gen-l10n
```

```text
test/
├── support/test_dependencies.dart    # base mémoire, secret store en RAM, batterie fixe
├── core/crypto_service_test.dart     # dérivation, signature, tailles, SHA-256
├── features/
│   ├── mesh/mesh_packet_codec_test.dart
│   └── alerts/alert_verifier_test.dart
└── widget_test.dart                  # onboarding FR → MG → permissions
tool/
├── alert_tool.dart                   # init / sign / verify (hors APK)
└── demo_authority.json               # clé privée de démonstration, hors assets
assets/
├── trusted_authorities.json          # clés publiques de confiance
└── demo/demo_alert.json              # alerte signée de démonstration
```

---

## 5. Découpage des modules

| Module | V1 | Data | Domain | Presentation |
|:---|:---:|:---|:---|:---|
| **Identity** | Oui | `flutter_secure_storage` pour la graine Ed25519 ; profil local dans Drift | `Identity`, `KeyPair`, `IdentityRepository`, génération au premier lancement | Onboarding, nom affiché, empreinte de clé, export de secours (V1.1) |
| **Chat** | Oui | DAO Drift, messages, accusés, receipts | `ChatMessage`, `MessageStatus`, `ChatRepository` | Salon, composer, bulles, badges de statut, liste des pairs |
| **Mesh** | Oui | BLE + transport simulé, codec binaire, outbox, `seen_packets` | `MeshPacket`, `MeshTransport`, `MeshEngine`, `DedupCache`, `RoutingPolicy`, `RelayPolicy` | État du relais, nombre de pairs, file d'attente, diagnostics |
| **Alerts** | Oui (démo) | Clés de confiance, alertes reçues | `SignedAlert`, vérification Ed25519, expiration, anti-rejeu | Bannière d'urgence, liste, détail, badge « vérifiée » |
| **Settings** | Oui | Drift + secure storage | Préférences typées | Langue, thème, relais, seuil batterie, permissions |
| **Diagnostics** | Oui | Fichiers de log rotatifs | `DiagnosticsRepository` | Export/copier les logs, état BLE/service/batterie |
| **Safety check-in** | Non (V2) | — | — | — |
| **Private chat / QR / sound / Wi-Fi Direct / LoRa** | Non | Interfaces réservées | — | — |

### 5.1 Flux d'un message sortant

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

### 5.2 Flux d'un message entrant

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

**Règle d'or :** le transport ne connaît ni le chat, ni les alertes, ni l'UI. Il transporte des octets.
Le `MeshEngine` ne connaît ni Flutter, ni Drift : il dépend de contrats.

### 5.3 Orchestration applicative

- `AppDependencies` (`bootstrap.dart`) construit une seule fois la base, le logger, la crypto, les
  repositories, les services Android et l'état initial. Il est injecté par surcharge de
  `appDependenciesProvider`.
- `SessionController` charge l'identité, le salon et l'état d'onboarding. `routerProvider` redirige
  automatiquement vers `/chat` quand l'onboarding est terminé.
- `MeshController` possède le `MeshRuntime` : démarrage, arrêt, changement de transport
  (BLE réel ou simulé), mise à jour des réglages et rafraîchissement des compteurs.
- `ChatController` sérialise les envois (un seul message en vol) et remonte les erreurs typées à l'UI.
- `AppRuntime` démarre le mesh après l'onboarding, affiche une notification pour chaque alerte
  vérifiée, rafraîchit les permissions au retour au premier plan et relance le mesh s'il a été arrêté.
- `DemoCompanion` n'est actif qu'en mode simulation : il joue le rôle de pairs virtuels, signe leurs
  ACK/reçus et publie un message d'accueil si le salon est vide.

**Point d'attention :** l'UI et le service de premier plan ne doivent jamais créer deux moteurs BLE
concurrents. En V1, `MeshRuntime` vit dans l'isolate principal ; le service de premier plan maintient
le processus en vie et relaie, mais le single-writer complet (service propriétaire de la base) reste
une évolution à valider en recette.

---

## 6. Protocole de maillage V1

### 6.1 Principes

- **Flooding contrôlé** avec TTL (7 par défaut, maximum 7) et déduplication par `messageId`.
- **Store-and-forward** : tout paquet utile reste en base jusqu'à expiration ou acquittement.
- **Jitter** aléatoire de 0 à 500 ms avant retransmission pour limiter les collisions.
- **Rate limiting** par expéditeur : 1 message / 2 s, 20 messages / minute, taille maximale 512 octets
  de texte utile (hors en-tête et signature).
- **Priorités** : alerte signée > accusé de livraison > message de chat.
- **Pas de routage adaptatif en V1** : le flooding est volontairement simple et testable. Le
  Spray-and-Wait / PRoPHET est réservé à la V2, après mesures de densité.

### 6.2 Enveloppe binaire versionnée

Un paquet est un tableau d'octets, encodé une seule fois par l'émetteur, puis **transmis tel quel**
par les relais (pas de ré-encodage, pas de re-signature).

```text
Offset  Taille  Champ                  Signé ?
0       4       magic "HFT1"           oui
4       1       version (2)            oui
5       1       type                   oui
6       1       ttl                    non (mutable)
7       1       hopCount               non (mutable)
8       2       payloadLength (BE)     oui
10      16      messageId              oui
26      8       channelId              oui
34      8       createdAt (ms, BE)     oui
42      8       senderId               oui
50      32      senderPublicKey        oui
82      64      signature Ed25519      —
146     N       payload                oui
```

- `signature` = Ed25519 sur la concaténation canonique des champs marqués « oui ».
- `senderId` = 8 premiers octets de `SHA-256(senderPublicKey)`.
- `channelId` = 8 premiers octets de `SHA-256("hafatra:neighborhood:" + code normalisé)`.
- `messageId` = UUID v7 (16 octets, ordonné dans le temps).
- `createdAt` en millisecondes UTC.
- `payload` : UTF-8 pour le chat, JSON canonique pour les alertes, structure binaire courte pour les
  accusés et receipts.
- Un paquet dont la signature, la version, la taille ou le `channelId` est invalide est **rejeté
  silencieusement** (compteur de diagnostics, pas de crash).

> **Note :** cette enveloppe fixe est préférée à JSON/CBOR pour réduire la surcharge sur BLE et pour
> rendre les tests de conformité reproductibles. Les vecteurs de test seront versionnés dans
> `test/fixtures/`.

### 6.3 Types de paquets V1

| Type | Valeur | Payload | Usage |
|:---|:---:|:---|:---|
| `chat` | 1 | JSON court `{n: nom, t: texte}` | Salon public |
| `alert` | 2 | Enveloppe JSON signée par l'autorité | Alerte cyclone / évacuation |
| `deliveryAck` | 3 | `messageId` (16) + statut (1) | Accusé de réception |
| `relayReceipt` | 4 | `messageId` (16) + hops (1) | Preuve d'observation par un relais |
| `safety` | 5 | Réservé V2 | « Je suis en sécurité » |
| `profile` | 6 | Réservé V1.1 | Nom, clé publique, version |

### 6.4 Statut de livraison honnête

Le statut n'est **jamais** « livré » sur la simple base d'un envoi local.

| Statut UI | Condition technique |
|:---|:---|
| **En attente** | Paquet en base, aucune transmission confirmée |
| **Envoyé au réseau** | Au moins un pair a accepté la trame |
| **Relayé par N** | N `relayReceipt` distincts reçus (N appareils différents) |
| **Vu par N** | N `deliveryAck` distincts (salon public) |
| **Livré** | Accusé du destinataire ciblé (messages privés, V2) |

Pour le salon public V1, l'UI affiche **« En attente » → « Envoyé au réseau » → « Relayé par N » →
« Vu par N »**. Le mot « Livré » est réservé aux messages privés, pour ne pas mentir sur une diffusion
de groupe.

### 6.5 Cycle de vie et rétention

- `outbox` : paquets non encore transmis, priorité + date, supprimés après transmission ou expiration.
- `seen_packets` : `messageId`, `firstSeenAt`, `expiresAt` (7 jours), purge horaire.
- `messages` : conservation par défaut de **30 jours** (constante `messageRetention`), purge horaire.
  Le plafond de 2 000 messages n'est pas implémenté en V1.
- `relay_receipts` et `delivery_acks` : supprimés quand le message associé disparaît.
- Les alertes expirées restent consultables mais ne déclenchent plus de bannière ; leur purge n'est pas
  encore planifiée.
- Aucun message n'est supprimé tant qu'il est dans l'outbox et non expiré.

---

## 7. Sécurité et vie privée

### 7.1 Modèle de menace V1

| Menace | Réponse V1 |
|:---|:---|
| Usurpation d'un expéditeur | Signature Ed25519 de chaque paquet |
| Fausse alerte | Signature d'autorité + clé publique de confiance + expiration |
| Rejeu | `messageId` + cache de déduplication + expiration des alertes |
| Flou artistique sur la confidentialité | Le salon public est **public par conception** : tout relais peut lire le contenu. L'UI l'indique explicitement. |
| Suivi radio | Jeton BLE éphémère aléatoire, regénéré à chaque démarrage du transport ; limite claire : les paquets publics révèlent la clé publique de l'expéditeur |
| Spam / flood | Rate limit, taille max, TTL, déduplication, blocage local d'un expéditeur |
| Vol de clé privée | Stockage chiffré par le Keystore Android ; pas d'export en clair sans confirmation |

### 7.2 Ce que la V1 ne promet pas

- Pas de **E2EE** pour le salon public : il faudra le dire dans l'onboarding et dans l'UI.
- Pas d'anonymat fort : un relais voit les clés publiques, le canal et les horaires.
- Pas de révocation d'autorité hors ligne : les clés de confiance ont une période de validité.
- Pas de protection contre un appareil compromis.
- Pas de chiffrement de la base locale au-delà du stockage applicatif Android ; le chiffrement
  SQLCipher est étudié en V2 si le besoin est confirmé.

### 7.3 Clés et identités

- Paire **Ed25519** générée au premier lancement.
- Graine privée stockée via `flutter_secure_storage` (Keystore Android).
- Clé publique = identité stable, affichée sous forme d'empreinte courte + QR plus tard.
- Pas de numéro de téléphone, pas de compte, pas de serveur d'identité.
- Les jetons BLE éphémères sont **aléatoires** et regénérés à chaque démarrage du transport ; ils ne
  sont **pas** utilisés comme identité applicative et ne sont pas dérivés de la clé d'identité.

### 7.4 Alertes signées

- Liste `assets/trusted_authorities.json` : `{id, name, publicKey, validFrom, validTo}`.
- Une alerte contient : `authorityId`, `alertId`, `severity`, `title`, `body`, `area`, `issuedAt`,
  `expiresAt`, puis une signature Ed25519 de l'autorité.
- L'app vérifie : signature, autorité connue, période de validité, `expiresAt`, `alertId` non rejoué.
- **Aucune clé de production** n'est embarquée sans un partenaire identifié. La clé de démonstration
  est présente dans `assets/trusted_authorities.json` pour **tous les builds** tant qu'aucune autorité
  réelle n'est configurée ; elle est explicitement nommée « Autorité de démonstration (non
  officielle) » et ne doit jamais servir à des alertes réelles. La retirer avant toute distribution
  publique.
- `tool/alert_tool.dart` (Dart, hors APK) : générer une paire, signer un fichier d'alerte, vérifier.
- Une alerte ne peut pas être « révoquée » hors ligne ; la durée de validité est la principale
  protection. À documenter avec les partenaires.

**Implémentation de démonstration livrée :**

```text
tool/demo_authority.json        clé privée de démo (hors assets, jamais dans l'APK)
assets/trusted_authorities.json autorité « Autorité de démonstration (non officielle) »
assets/demo/demo_alert.json     alerte cyclone-001, valide jusqu'au 2030-12-31
```

Commandes utiles :

```bash
dart run tool/alert_tool.dart init \
  --out tool/demo_authority.json --authorities assets/trusted_authorities.json
dart run tool/alert_tool.dart sign \
  --key tool/demo_authority.json --out assets/demo/demo_alert.json \
  --severity warning --title "..." --body "..." --area "..."
dart run tool/alert_tool.dart verify \
  --alert assets/demo/demo_alert.json --authorities assets/trusted_authorities.json
```

`verify` renvoie un code de sortie non nul si l'alerte est refusée, ce qui permet de l'intégrer à une
chaîne de contrôle. `--force` est requis pour écraser une clé existante. La graine privée n'est
**jamais** copiée dans `assets/`.

---

## 8. Transport Bluetooth et arrière-plan

### 8.1 Pourquoi `bluetooth_low_energy`

- Supporte **central + peripheral** sur Android : indispensable pour qu'un téléphone puisse à la fois
  scanner et servir des paquets à d'autres téléphones.
- `flutter_blue_plus` est excellent en central mais ne fournit pas le rôle périphérique nécessaire au
  maillage ; il est donc écarté pour ce besoin.
- `bluetooth_low_energy` 6.2.1, `minSdk 24`, publishé par un éditeur vérifié.

### 8.2 Rôle de chaque téléphone

Chaque appareil :

1. diffuse un advertisement avec un UUID de service Hafatra et un jeton éphémère ;
2. scanne les advertisements Hafatra ;
3. ouvre une connexion GATT vers un pair ;
4. échange des trames chunkées sur une caractéristique d'écriture/notification ;
5. ferme la connexion après inactivité (backoff et limite de connexions simultanées).

Les doublons de connexion (A→B et B→A) sont résolus par une règle déterministe basée sur les
identifiants éphémères. Les trames sont idempotentes grâce à `messageId`.

**Détails du profil GATT :**

| Élément | Valeur |
|:---|:---|
| Service | `51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0001` |
| Caractéristique « inbox » (écriture centrale → périphérique) | `...0002` |
| Caractéristique « outbox » (notifications périphérique → centrale) | `...0003` |
| Advertisement | UUID de service + jeton aléatoire de 8 octets en `serviceData` ; **aucun nom local** |
| Découpage | en-tête de 7 octets : version (1), transferId (2, BE), index (1), total (1), longueur de trame (2, BE) |
| Taille utile | 176 octets par écriture, ajustée au MTU négocié ; 255 chunks maximum |
| Sécurité | écriture `withResponse` ; la trame HFT1 complète est réassemblée avant vérification |

Le jeton sert uniquement à départager deux téléphones qui se découvrent mutuellement ; il n'est ni
persisté ni utilisé comme identité.

### 8.3 Service de premier plan

- `flutter_foreground_task` 11.0.3 (mis à jour récemment, Flutter 3.44+) plutôt que
  `flutter_background_service` (dernière version 5.1.0 de décembre 2024).
- Type de service Android : `connectedDevice` (+ `remoteMessaging` si la politique Play le permet),
  avec `FOREGROUND_SERVICE_CONNECTED_DEVICE` et les permissions BLE.
- Notification persistante : « Hafatra relaye les messages autour de vous » avec bouton pause.
- **Choix V1 :** le handler du service reste minimal (`TaskHandler` vide). Le moteur BLE vit dans
  l'isolate principal ; le service de premier plan maintient le processus actif et empêche sa mise en
  veille, sans ouvrir une seconde base ni un second émetteur BLE.
- Le single-writer complet (service propriétaire de la base, UI en simple lecteur via IPC) est une
  évolution prévue, à valider pendant la recette terrain. Il éviterait les écritures concurrentes si
  l'application est tuée puis relancée par le système.

### 8.4 Assistant anti-arrêt

Écran dédié, déclenché après l'onboarding :

- explication simple du problème (Tecno, Infinix, Xiaomi, Samsung) ;
- bouton « Autoriser l'activité en arrière-plan » (batterie) ;
- bouton « Ouvrir les réglages du constructeur » quand une intent est connue ;
- bouton « Tester le relais » avec un diagnostic (service actif, permissions, batterie) ;
- rappel non intrusif si le service est tué.

Aucune promesse miracle : le texte explique que le constructeur peut encore arrêter l'application.

### 8.5 Stratégie batterie

| Niveau | Comportement implémenté |
|:---|:---|
| > 30 % ou en charge | Relais normal (tous types) |
| 15–30 % | Relais limité aux alertes, accusés et reçus de relais |
| < seuil (15 % par défaut) | Relais suspendu ; l'UI signale la batterie faible et propose de recharger |
| Mode économie Android | Respect du statut système ; pas de contournement |

Le scan et l'advertising ne sont pas coupés en V1 pour éviter des reconnexions coûteuses ; seule la
retransmission est restreinte. Les seuils sont configurables dans Réglages (15 % par défaut, bornes
5–40 %). L'effet réel sur la consommation devra être mesuré en recette.

---

## 9. Persistance

**Drift 2.35.2 + `drift_flutter` 0.3.1**, plutôt que `sqflite` :

- requêtes typées et **streams réactifs** (l'UI se met à jour sans polling) ;
- migrations versionnées et testables ;
- support des isolates, utile pour le service de premier plan ;
- `sqlite3_flutter_libs` est marqué **EOL** ; `drift_flutter` s'appuie sur `sqlite3` avec les native
  assets, ce qui évite une dépendance en fin de vie.

Tables proposées :

```text
identities        (id, public_key, display_name, created_at)
channels          (id, code_hash, code, name, joined_at)
messages          (id, channel_id, sender_id, sender_name, body, created_at,
                   direction, status, priority, expires_at,
                   is_alert, alert_authority, relay_count, seen_count)
packets_outbox    (packet_id, message_id, bytes, priority, created_at,
                   next_attempt_at, attempts, expires_at)
seen_packets      (packet_id, first_seen_at, expires_at)
relay_receipts    (id, message_id, relay_id, hops, received_at)
delivery_acks     (id, message_id, ack_sender_id, status, received_at)
trusted_alerts    (alert_id, authority_id, payload, severity, title, body,
                   received_at, expires_at)
peers             (id, transport, display_name, rssi, last_seen_at)
settings          (key, value)
```

- Mode WAL activé.
- Index sur `(channel_id, created_at)`, `(expires_at)`, `(status, priority)`.
- Purge au démarrage + toutes les heures.
- Tests de migration avec `drift_dev schema` et bases de test en mémoire.

---

## 10. Design System

### 10.1 Palette

Les teintes de marque sont stables ; la profondeur vient de la rampe de surfaces, pas des bordures.

| Token | Light | Dark | Usage |
|:---|:---|:---|:---|
| `primary` | `#0B4F4A` | `#7FD1C7` | Identité, actions principales |
| `onPrimary` | `#FFFFFF` | `#062B28` | Texte sur primary |
| `primaryContainer` | `#CFE8E2` | `#0F3B37` | Puces, pastille de navigation sélectionnée |
| `secondary` | `#8A5A00` | `#FFC857` | Accents ambre, bandeaux d'information |
| `secondaryContainer` | `#FFE2A8` | `#5C4200` | Fonds ambre |
| `tertiary` | `#C73E1D` | `#FFB4A2` | Urgence |
| `ink` / `onSurface` | `#141C1A` | `#E6EFEC` | Texte principal |
| `inkMuted` / `onSurfaceVariant` | `#4E5C58` | `#A3B2AD` | Texte secondaire |
| `outline` | `#6F7B78` | `#8A9692` | Bordures et libellés discrets |
| `success` | `#2E7D32` | `#81C784` | Livré / vérifié |
| `warning` | `#B26A00` | `#FFB74D` | En attente / batterie |
| `error` | `#B3261E` | `#F2B8B5` | Erreur |

**Cinq niveaux de surface** (`AppSurfaces`, exposé comme `ThemeExtension`, lu via `context.surfaces`) :

| Niveau | Light | Dark | Rôle |
|:---|:---|:---|:---|
| `lowest` | `#FFFFFB` | `#05100E` | `card` en clair |
| `low` | `#F5F3EC` | `#0A1614` | Sous-cartes |
| `base` | `#EFEEE6` | `#101D1A` | Fond de page |
| `high` | `#E8E6DC` | `#172623` | `card` en sombre |
| `highest` | `#DFDCD1` | `#1F312D` | `field` (champs, pastilles) |

- `card` = `lowest` en clair, `high` en sombre : une carte est **toujours** au-dessus de la page.
- `field` = `highest` dans les deux thèmes : un champ de saisie est toujours **en retrait**.
- `hairline` / `hairlineStrong` : filets 8 % et 14 % d'encre, réservés aux séparateurs internes.
- `shadow` / `glow` : alimentent `AppElevation` ; le `glow` est teinté de marque, jamais noir.

**Dégradés de marque** (`AppGradients`, lu via `context.gradients`) :

| Dégradé | Light | Dark |
|:---|:---|:---|
| `brand` (bulles sortantes, boutons pleins) | `#13796E → #0B4F4A` | `#0F6E63 → #0C5C55` |
| `hero` (maillage, à-propos) | `#0B4F4A → #06332F` | `#10514B → #06221F` |
| `brandInk` (encre posée sur ces dégradés) | `#F2FBF8` | `#EAFBF6` |

> **Règle `brandInk`.** `brand` et `hero` restent teal foncé dans les deux thèmes, alors que
> `scheme.onPrimary` s'inverse (`#062B28` en sombre). Écrire `onPrimary` sur un dégradé de marque
> produit un texte quasi illisible : **le texte et les icônes sur `brand`/`hero` utilisent toujours
> `gradients.brandInk`.**

Contraste vérifié (WCAG, point le plus défavorable de chaque rampe) : texte courant `ink` sur
`card`/`base` **17.3 / 14.9:1 (AAA)** ; `inkMuted` **6.99:1 (AA)** ; `onPrimary` sur `primary`
**9.41:1 (AAA)** ; `brandInk` sur `brand` **5.7:1 (AA)** et sur `hero` **8.5:1 (AAA)** ; bandeaux
`InfoBanner` (teinte 8–12 % sur `card`) **≥ 10:1 (AAA)**. Visée : **AA** pour le texte courant,
**AAA** pour les alertes critiques. Aucun statut ne doit être signalé uniquement par la couleur
(icône + texte + forme).

### 10.2 Typographie

- **Inter variable embarquée** (`assets/fonts/InterVariable-subset.ttf`, 250 Ko sous-ensemblée au
  jeu de caractères réellement utilisé : latin FR/MG, ponctuation, chiffres, `%`, `#`). C'est le seul
  fichier de police de l'application ; le surcoût d'APK est assumé pour la cohérence du rendu.
- `fontFamily: 'Inter'` est posé sur le `TextTheme` complet ; les corps de texte montent l'axe
  optique automatiquement : `FontVariation('opsz', …)` suit la taille.
- Échelle : `displaySmall` 32, `headlineSmall` 24, `titleLarge` 20, `titleMedium` 16,
  `bodyLarge` 16, `bodyMedium` 14, `labelLarge` 14, `labelSmall` 12 ; crénage négatif sur les grands
  corps, graisses 650/700 pour les titres (`const FontWeight(650)`).
- Hauteur de ligne 1.35–1.5 ; texte de chat 16sp ; boutons 16sp.
- Support du scale système jusqu'à 1.3 sans débordement (tests widget).
- Malgache et français utilisent l'alphabet latin ; vérifier les diacritiques (ô, à, é, è) dans les
  captures et les tests de rendu.

### 10.3 Espacement, formes, élévation, mouvement

- Espacements (`AppSpacing`) : 4, 8, 12, 16, 24, 32, 48, plus `gutter` 20 (marge latérale commune)
  et `sectionGap` 20 (respiration entre blocs).
- Rayons (`AppRadius`) : `sm` 10 (chips, coins serrés), `md` 14 (champs), `lg` 22 (cartes et bulles),
  `xl` 28 (feuilles), `xxl` 34 (hero), `pill` 999. `AppRadius.bubble()` ne serre qu'un coin, du côté
  de l'expéditeur.
- **Élévation (`AppElevation`) : la lumière vient en haut à gauche** (décalage x positif, y plus
  grand) et chaque niveau empile deux ombres (une large + une serrée) : `low` 8/2, `medium` 20/6,
  `high` 36/10, plus `glow()` pour les halos de marque. Une carte ne se distingue **jamais** par une
  bordure.
- Cibles tactiles : 48×48 dp minimum.
- Mouvement (`AppMotion`) : `press` 120 ms, `reveal` 180 ms, `emphasized` 260 ms, `hero` 380 ms ;
  courbes `easeOutCubic` (standard) et `easeOutBack` (ressort). Toute animation passe par ces
  constantes et se coupe via `AppMotion.reduceMotion(context)` (demande système « réduire les
  animations »).
- Icônes Material intégrées ; pas de police d'icônes supplémentaire en V1.
- Mode sombre dès la V1 (économie de batterie OLED et usage nocturne).

### 10.4 Composants clés

- `_MessageBubble` : texte, heure, statut, auteur (salon), état d'échec avec action « Réessayer ».
- `StatusBadge` : icône + libellé + compteur, jamais une simple coche ambiguë.
- `MetricTile` / cartes du maillage : « Relais actif », « N appareils à portée », « Batterie faible ».
- `InfoBanner` : couleur d'urgence ou d'information, nom de l'autorité, bouton « Voir ».
- `EmptyState` : rappel que l'application fonctionne sans Internet et invite à patienter.
- `AppCard` / `SectionHeader` : structure commune des écrans de réglages et de diagnostics.
- Cartes de permission : expliquent pourquoi une permission est demandée avant de la demander.
- `LiveDot` : pastille d'état animée ; l'abonnement au thème se prend dans
  `didChangeDependencies`, jamais dans `initState` (sinon `dependOnInheritedWidgetOfExactType` lève
  une assertion).
- Navigation (`shell.dart`) : quatre libellés courts localisés (`navChat`, `navAlerts`, `navMesh`,
  `navSettings` → « Salon / Alertes / Maillage / Réglages »). Le style est porté par
  `navigationBarTheme` (11,5 sp, graisse 700/500) et non par le widget : à 12 sp, « Fampitandremana »
  (Alertes en malgache) se cassait sur deux lignes et décalait la barre. L'icône sélectionnée est
  colorée par `navigationBarTheme.iconTheme` (`onPrimaryContainer`), car `NavigationBar` n'expose pas
  de paramètre `iconTheme` direct.

---

## 11. Internationalisation

- `flutter_localizations` + `intl` 0.20.3 + `gen-l10n`.
- Fichiers ARB : `app_fr.arb` (template de génération) et `app_mg.arb`.
- Locale par défaut : **français** (`fr`), malgache (`mg`) disponible via le sélecteur et les réglages.
- Les libellés de statut, permissions, alertes et erreurs sont **tous** localisés ; aucun texte en dur
  dans les widgets.
- Pluriels ICU pour « N appareils », « N messages », « N minutes ».
- Les formats de date/heure utilisent `intl` ; si une locale n'est pas complète, fallback français.
- Le contenu utilisateur n'est jamais traduit ni tronqué sans indication.
- Les logs techniques restent en anglais (lisibilité pour le support), l'UI en malgache/français.
- **Repli Material/Cupertino :** Flutter ne fournit pas de `MaterialLocalizations` ni de
  `CupertinoLocalizations` pour `mg`. `lib/core/l10n/l10n.dart` ajoute des delegates qui délèguent ces
  widgets système au français, tout en conservant les textes Hafatra en malgache. Sans ce repli,
  l'ouverture d'un sélecteur de date ou d'un menu Material lèverait une assertion en locale `mg`.
- Les clés ARB sont vérifiées par `flutter gen-l10n` ; toute clé ajoutée au template doit exister dans
  `app_mg.arb` (sinon la génération échoue).
- Les quatre libellés de navigation (`navChat`, `navAlerts`, `navMesh`, `navSettings`) sont volontairement
  courts — un mot par destination — pour tenir sur une ligne en français comme en malgache ; la barre de
  navigation n'a pas de retour à la ligne.

---

## 12. Gestion des erreurs et journalisation

### 12.1 Erreurs

Hiérarchie scellée dans `core/errors/app_exception.dart` :

```text
AppException
├── TransportException      (BLE indisponible, permission, connexion perdue)
├── StorageException        (DB, migration, disque plein)
├── CryptoException         (signature invalide, clé absente)
├── ValidationException     (message vide/trop long, canal invalide)
├── PermissionException     (refus utilisateur)
└── UnknownException
```

- Les couches basses lancent des exceptions typées ; les repositories les traduisent.
- L'UI utilise `AsyncValue`, affiche un message localisé générique (`errorGeneric`) et propose une
  action (« Réessayer », « Ouvrir les réglages »). Les erreurs de validation peuvent afficher leur
  message métier (`AppException.message`) lorsqu'il ne contient aucune donnée sensible. Un
  `ErrorMapper` centralisé reste une amélioration souhaitable pour V1.1.
- Aucun `catch` silencieux. Les erreurs attendues sont loguées en `warning`, les inattendues en `error`.
- Les paquets invalides ne font pas planter l'application : rejet + compteur.

### 12.2 Logs

- `logging` 1.3.0 + sink console (debug) + fichier rotatif (tous les modes).
- Fichier : `getApplicationSupportDirectory()/logs/hafatra.log`, rotation à 512 Ko, **1 archive**
  (`hafatra.log.1`).
- `hierarchicalLoggingEnabled = true` est activé avant de régler le niveau du logger non-racine ;
  sans cela, `logging` lève `UnsupportedError` au démarrage.
- Niveaux : `FINE` en debug, `INFO` en release.
- **Jamais** de contenu de message, de clé privée, de nom complet ou de localisation précise dans les
  logs. Les identifiants sont tronqués.
- Écran Diagnostics : état BLE, service, batterie, permissions, version, nombre de paquets, export
  des logs par presse-papiers (pas de réseau).
- Gestion globale : `FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded`.
- Pas d'analytics ni de crash reporting distant par défaut (souveraineté et hors-ligne).

---

## 13. Dépendances

> Versions verrouillées dans `pubspec.lock` après résolution du 2026-10-20. Les contraintes du
> `pubspec.yaml` utilisent `^` pour les correctifs, mais l'APK se construit toujours avec le lockfile.

### Runtime

| Package | Version | Rôle | Justification |
|:---|:---:|:---|:---|
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
| `permission_handler` | 12.0.1 | Permissions | BLE, notifications, batterie ; voir note de compatibilité ci-dessous |
| `bluetooth_low_energy` | 6.2.1 | BLE | Central + peripheral |
| `flutter_foreground_task` | 11.0.3 | Service Android | Maintenu, Flutter récent |
| `battery_plus` | 7.1.2 | Batterie | Politique de relais |
| `flutter_local_notifications` | 22.3.2 | Notifications | Alertes et service |
| `package_info_plus` | 10.2.2 | Diagnostics | Version de l'app |
| `device_info_plus` | 13.3.0 | Diagnostics | Constructeur/modèle |
| `flutter_localizations` | SDK | Localisations | Material/Cupertino avec repli `mg` |

### Développement

| Package | Version | Rôle |
|:---|:---:|:---|
| `build_runner` | 2.16.2 | Génération Drift |
| `drift_dev` | 2.35.1 | Générateur Drift |
| `very_good_analysis` | 11.0.0 | Lints stricts |
| `mocktail` | 1.0.5 | Mocks |
| `flutter_test` | SDK | Tests |
| `integration_test` | SDK | Tests d'intégration (harnais prêt, scénarios à ajouter) |

**Écartés après arbitrage :** `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`
et `riverpod_lint`/`custom_lint`. Les entités V1 sont peu nombreuses et écrites à la main ; les
supprimer réduit le temps de génération, les dépendances transitives et les frictions de lints. Drift
reste le seul générateur nécessaire.

**Note `permission_handler` :** `permission_handler_android` 14.x déclare `compileSdk = 37`. Le SDK
installé expose le dossier `platforms/android-37.0`, tandis qu'AGP 9.1 cherche `android-37` : le build
échoue. La solution retenue est de pinner `permission_handler: 12.0.1` (API Dart stable) et
`permission_handler_android: 13.0.1` (compileSdk 35) via `dependency_overrides`, en attendant un
correctif amont ou une plateforme SDK 37 nommée `android-37`. Cette épingle est documentée dans
`pubspec.yaml` et devra être retirée dès que possible.

**Non retenus :** `sqflite` (pas de streams réactifs), `sqlite3_flutter_libs` (EOL),
`flutter_background_service` (moins récent), `flutter_blue_plus` (pas de rôle périphérique),
`provider` (Riverpod couvre le besoin), `get_it` (Riverpod fait l'injection).

---

## 14. Tests et qualité

### 14.1 État des tests automatisés

| Fichier | Couverture | Nombre |
|:---|:---|:---:|
| `test/core/crypto_service_test.dart` | Dérivation déterministe, signature/vérification, altérations, SHA-256, tailles invalides | 7 |
| `test/features/mesh/mesh_packet_codec_test.dart` | Round-trip, tampering payload/expéditeur, signature, TTL/hops, magic/version/longueur, UUID invalide | 11 |
| `test/features/alerts/alert_verifier_test.dart` | Alerte valide, autorité inconnue, expirée, future, hors période, signature/contenu altérés, JSON invalide, alerte embarquée | 6 |
| `test/widget_test.dart` | Onboarding FR → validation du nom → profil → bascule malgache → mode démo → permissions | 1 |
| **Total** | `flutter test` | **25 verts** |

Le harnais `test/support/test_dependencies.dart` fournit une base Drift en mémoire, un
`InMemorySecretStore`, une source de batterie statique et un logger silencieux. Aucun test ne touche au
Keystore, au BLE réel, aux fichiers de logs ni au réseau.

### 14.2 Portes qualité

```bash
dart format --set-exit-if-changed lib test tool
flutter analyze                 # objectif : 0 erreur, 0 info
flutter test
flutter build apk --debug       # réussi le 2026-10-21
```

État au 2026-10-21 (contrôle du redesign) : `dart format --set-exit-if-changed lib test` ne change
rien, `flutter analyze --no-pub lib` renvoie **« No issues found! »**, `flutter test` passe
**25/25**, et `flutter build apk --debug` produit
`build/app/outputs/flutter-apk/app-debug.apk`. Gradle émet un avertissement de migration Kotlin pour
`bluetooth_low_energy_android` ; il n'est pas bloquant mais devra être suivi.

- Couverture cible : **≥ 80 %** sur `domain/` et `mesh/` (codec, crypto, politiques). La couverture
  n'est pas encore mesurée ; lancer `flutter test --coverage` puis `genhtml` ou le rapport de l'IDE.
- Aucun `print` en production ; `AppLogger` uniquement.
- Aucun `dynamic` non justifié ; `strict-casts`, `strict-inference`, `strict-raw-types`.
- Analyse statique avec `very_good_analysis`. Les quelques exceptions (`document_ignores`,
  `specify_nonobvious_property_types`, `omit_local_variable_types`) sont commentées dans le code.

### 14.3 Limites assumées des tests

- Le transport BLE n'est **pas** couvert par un test automatisé : il dépend du matériel, des
  permissions runtime et du service Android. Il sera validé par la recette terrain.
- Le transport simulé est couvert indirectement par le codec, mais un test d'intégration multi-nœuds
  (3 à 5 nœuds, propagation, doublons, coupure) reste à écrire.
- Les migrations Drift sont testées par ouverture d'une base neuve en mémoire ; la migration depuis
  une version antérieure devra être ajoutée dès la première évolution de schéma.
- Le widget test couvre l'onboarding ; chat, alertes, réglages et diagnostics restent à couvrir.
- **Aucun test golden n'est versionné.** Le rendu visuel du redesign a été contrôlé avec un harnais
  temporaire (14 captures clair/sombre, toutes les écrans) puis supprimé. Un golden stable demande
  de charger Inter et `MaterialIcons` via `dart:ui loadFontFromList` (les tests tournent sinon avec
  la police de test), d'immobiliser `LiveDot` et de figer l'horloge — les libellés de date produits
  par un `FixedClock` exécutent aussi des égalités d'horodatage départagées par UUID, ce qui rend
  l'ordre de deux messages proches aléatoire. À reprendre en test dédié si l'on veut un verrou
  visuel durable.

### 14.4 Recette terrain minimale

1. 2 téléphones : envoi, accusé, statut.
2. 3 téléphones : relais par un intermédiaire, TTL.
3. 5+ téléphones : doublons, ordre, batterie.
4. Marques : Tecno, Infinix, Xiaomi, Samsung (si disponibles).
5. Écran éteint / app en arrière-plan / service tué par le constructeur.
6. Mode avion, Bluetooth coupé, redémarrage du téléphone.
7. Alerte signée valide, alerte falsifiée, alerte expirée.
8. Batterie : 1 heure de relais actif, mesure de la consommation.

---

## 15. Plan de développement incrémental

| Étape | Livrable | État |
|:---:|:---|:---|
| **0** | Projet Flutter, lints, thème, i18n, structure, CI locale | **Fait** — analyse sans erreur, format propre |
| **1** | Identité Ed25519, onboarding, stockage sécurisé, base Drift | **Fait** — tests crypto + widget onboarding |
| **2** | Salon de quartier, stockage local, UI, statuts, réglages de base | **Fait** — UI et streams Drift en place |
| **3** | Codec, signatures, `MeshEngine`, transport simulé multi-nœuds | **Partiel** — codec et moteur testés ; test d'intégration multi-nœuds à écrire |
| **4** | BLE central/périphérique, permissions, service de premier plan, assistant anti-arrêt | **Code écrit, APK debug construit** — validation BLE et arrière-plan sur téléphones en attente |
| **5** | Alertes signées, clés de confiance, CLI de signature, bannière | **Fait** — CLI, assets de démo, vérificateur testés |
| **6** | Durcissement, purge, performances, accessibilité, APK release | **À faire** — après recette BLE |

Chaque étape se termine par : code formaté, analyse sans erreur, tests verts, mise à jour de ce document
et courte note de décision.

### 15.1 Écrans livrés

| Écran | Route | Contenu |
|:---|:---|:---|
| Onboarding | `/` | Nom affiché, nom du quartier, choix FR/MG, mode démo, demande des permissions |
| Chat | `/chat` | Salon public, bannière d'alerte, bulles avec statut, composer |
| Alertes | `/alerts` | Liste vérifiée/expirée, détail avec autorité et empreinte |
| Maillage | `/mesh` | État du transport, pairs, file d'attente, paquets vus, batterie, bascule démo/BLE |
| Réglages | `/settings` | Langue, thème, relais, seuil batterie, notifications, accès diagnostics/à propos |
| Diagnostics | `/diagnostics` | Version, appareil, permissions, transport, journaux récents, export |
| À propos | `/about` | Version, limites de la V1, absence de serveur et d'E2EE sur le salon public |

Les états de chargement, d'erreur et vides utilisent des composants partagés
(`lib/core/widgets/app_widgets.dart`). Les erreurs métier sont traduites par `ErrorMapper` et
accompagnées d'une action (« Réessayer », « Ouvrir les réglages »).

### 15.2 Mode démonstration

Le mode démo remplace le transport BLE par `SimulatedTransport` et active `DemoCompanion` :

- pairs virtuels avec latence et taux de perte simulés ;
- ACK et reçus signés par les clés de démo des pairs, pour exercer les compteurs `seenCount` et
  `relayCount` ;
- message d'accueil publié uniquement si le salon est vide ;
- alerte de démonstration embarquée, vérifiable via l'autorité de confiance de démo ;
- service de premier plan **non démarré** : la simulation reste légère et ne demande pas les
  permissions Android.

Le mode démo est activable depuis l'onboarding ou les réglages. Il ne prouve pas le BLE : il valide le
produit, les statuts et le parcours d'alerte sur un seul appareil.

---

## 16. Risques et parades

| Risque | Gravité | Parade |
|:---|:---:|:---|
| BLE non validable sans téléphone physique | Élevée | Transport simulé dès l'étape 3 ; recette terrain planifiée ; ne pas déclarer « prêt » avant tests réels |
| Constructeurs qui tuent le service | Élevée | Assistant anti-arrêt, guide par marque, test réel, fallback « relais seulement quand l'app est ouverte » |
| Android 14/15 : restrictions de service de premier plan | Élevée | Type `connectedDevice`, permissions explicites, test sur API 34/35, documentation Play |
| Densité insuffisante | Élevée (produit) | Pilote dans un lieu dense ; bornes fixes V3 ; ne pas promettre une couverture rurale |
| Salon public lu par tous | Moyenne | Information claire dans l'UI ; E2EE réservé aux messages privés V2 |
| Spam / flood | Moyenne | Rate limit, TTL, déduplication, blocage local |
| Batterie | Moyenne | Politique de seuils, mode économie, mesures |
| Clé d'alerte compromise | Élevée | Durée de validité courte, clés de confiance, procédure de rotation hors ligne |
| APK trop lourd | Moyenne | Une seule police embarquée (Inter variable sous-ensemblée, 250 Ko), pas d'images lourdes, split-per-ABI, obfuscation, mesures |
| Conflit de licence Android | Faible | Build debug réussi ; licences restantes à accepter pour le release. Épinglage `permission_handler` documenté. |

---

## 17. Checklist pré-exécution

- [x] Lire le document de réflexion et en extraire le périmètre, les risques et les questions ouvertes.
- [x] Vérifier l'environnement Flutter/Dart/Android et identifier les limites de validation.
- [x] Rechercher les packages sur pub.dev et vérifier leurs versions, leur maintenance et leurs rôles.
- [x] Choisir l'architecture, la gestion d'état, la persistance, le transport et la stratégie de test.
- [x] Définir le design system de base (couleurs, typographie, espacements, accessibilité).
- [x] Définir la stratégie i18n (malgache/français).
- [x] Définir la stratégie d'erreurs et de journalisation.
- [x] **D1 — périmètre : cœur multi-transport, BLE + simulation fonctionnels.**
- [x] **D2 — BLE réel + simulation, service de premier plan.**
- [x] **D3 — alertes de démo + clé importable + CLI.**
- [x] **D4 — Hafatra, français par défaut, malgache disponible.**
- [x] **D5 — « Je suis en sécurité » reporté en V2.**
- [x] Confirmer la disponibilité de téléphones Android pour la recette BLE (2+).
- [x] Confirmer l'identifiant d'application (`mg.hafatra`) et le nom affiché (`Hafatra`).
- [x] Implémenter le socle, les features, l'UI, le routeur, le CLI et les assets de démonstration.
- [x] Écrire et faire passer les tests (25/25) ; `flutter analyze` sans erreur.
- [x] Construire l'APK debug (`build/app/outputs/flutter-apk/app-debug.apk`).
- [ ] Accepter les licences Android restantes (`flutter doctor --android-licenses`) pour le build release.
- [ ] Installer l'APK sur les téléphones et valider le BLE réel.
- [ ] Valider le service d'arrière-plan et la consommation batterie sur 2+ téléphones.
- [ ] Écrire le test d'intégration multi-nœuds sur transport simulé.
- [ ] Remplacer l'icône launcher Flutter par l'identité visuelle Hafatra.

---

## 18. Points encore ouverts (non bloquants pour coder)

1. **Autorité réelle** : quelle organisation (protection civile, mairie, ONG) fournira la première
   clé publique de production ? En attendant, seule la clé de démonstration est active.
2. **Identifiant Play Store / nom de package** : `mg.hafatra` est utilisé pour le prototype. Il pourra
   être changé avant une publication officielle.
3. **Recette terrain** : les deux téléphones du porteur permettront de valider le BLE, mais il faudra
   organiser un test à 15–30 appareils dans un lieu dense.
4. **Licences Android et SDK 37** : le build debug fonctionne, mais les licences restantes doivent être
   acceptées pour un release, et l'épingle `permission_handler_android 13.0.1` devra être levée quand
   l'outillage résoudra `android-37.0` correctement.
5. **Design final** : la palette et la typographie de base sont définies ; l'identité visuelle
   (logo, icône, captures) reste à finaliser avec le porteur. L'icône launcher est encore celle de
   Flutter.

---

*Document de pré-coding validé. L'implémentation démarre par le socle Flutter, puis les tranches
verticales décrites au §15.*
