# Données, persistance et confidentialité

> **Statut : implémenté et vérifié.** La persistance locale est complète en V1. Le chiffrement de la base au-delà du stockage applicatif Android reste à décider.

## 1. Vue d'ensemble

Trois Stockages, trois mots de passe :

| Stockage | Technologie | Contenu | Sensibilité |
|:---|:---|:---|:---|
| **Base locale** | Drift / SQLite (`hafatra`) | Messages, salons, outbox, alertes, réglages, pairs | Moyenne |
| **Coffre de secrets** | `flutter_secure_storage` (Keystore Android) | Graine Ed25519 de l'identité | **Critique** |
| **Journalisation** | Fichier rotatif + tampon mémoire | Journaux techniques, jamais de contenu | Faible |

**Règle de souveraineté.** Rien ne sort de l'appareil sauf par Bluetooth Low Energy, vers les appareils du quartier. Aucun compte, aucun serveur, aucune télémétrie.

## 2. Pourquoi Drift et non `sqflite`

- **Requêtes typées** : les erreurs de schéma deviennent des erreurs de compilation.
- **Streams réactifs** : l'interface se met à jour via `watch()`, sans polling ni `setState` manuel.
- **Migrations versionnées** et testables.
- **Support des isolates**, utile pour le service de premier plan.
- `sqlite3_flutter_libs` est marqué **fin de vie** ; `drift_flutter` s'appuie sur `sqlite3` via les native assets, ce qui évite une dépendance abandonnée.

**Connexions** : `driftDatabase(name: 'hafatra', native: DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory))`. La base vit dans le répertoire de support de l'application, pas dans le stockage externe.

## 3. Schéma

Dix tables. Le code généré est dans `app_database.g.dart` (régénéré par `build_runner`).

### `identities`

| Colonne | Type | Rôle |
|:---|:---|:---|
| `id` | texte, PK | Identifiant dérivé : 8 premiers octets du SHA-256 de la clé publique, en hexadécimal |
| `publicKey` | blob | Clé publique Ed25519 (32 octets) |
| `displayName` | texte | Nom affiché, 40 caractères maximum |
| `createdAt` | date | Création de l'identité |

### `channels`

| Colonne | Type | Rôle |
|:---|:---|:---|
| `id` | texte, PK | Identifiant du salon |
| `code` | texte | Code de quartier normalisé |
| `codeHash` | blob | SHA-256 du code normalisé |
| `name` | texte | Nom du salon |
| `joinedAt` | date | Date d'adhésion |

### `messages`

| Colonne | Type | Rôle |
|:---|:---|:---|
| `id` | texte, PK | Identifiant du message |
| `channelId` | texte | Salon de rattachement |
| `senderId`, `senderName` | texte | Expéditeur |
| `body` | texte | Contenu (512 octets maximum) |
| `createdAt` | date | Date d'émission |
| `direction` | entier | Sortant (1) ou entrant (0) |
| `status` | entier | `queued`, `sent`, `relayed`, `seen`, `delivered` |
| `priority` | entier | Alerte 100, accusé 60, reçu 40, chat 20 |
| `expiresAt` | date, nullable | Fin de validité |
| `isAlert` | booléen | Vrai pour une alerte |
| `alertAuthority` | texte, nullable | Autorité signataire |
| `relayCount` | entier | Nombre d'appareils ayant relayé |
| `seenCount` | entier | Nombre d'accusés de réception |
### `packets_outbox` — file d'attente d'envoi

| Colonne | Type | Rôle |
|:---|:---|:---|
| `packetId` | texte, PK | Identifiant du paquet |
| `messageId` | texte | Message associé |
| `bytes` | blob | Paquet sérialisé prêt à émettre |
| `priority` | entier | Priorité de départ |
| `createdAt` | date | Mise en file |
| `nextAttemptAt` | date | Prochaine tentative autorisée |
| `attempts` | entier | Nombre de tentatives |
| `expiresAt` | date | Abandon au-delà de cette date |

### `seen_packets` — anti-rejeu

| Colonne | Type | Rôle |
|:---|:---|:---|
| `packetId` | texte, PK | Identifiant du paquet déjà traité |
| `firstSeenAt` | date | Première réception |
| `expiresAt` | date | Purge après 7 jours |

### `relay_receipts` et `delivery_acks`

| Table | Clé | Contenu |
|:---|:---|:---|
| `relay_receipts` | unique `(messageId, relayId)` | Un relais a transmis le message, en `hops` sauts, à `receivedAt` |
| `delivery_acks` | unique `(messageId, ackSenderId)` | Un destinataire a vu le message, avec son `status` |

### `trusted_alerts`

| Colonne | Type | Rôle |
|:---|:---|:---|
| `alertId` | texte, PK | Identifiant de l'alerte |
| `authorityId` | texte | Autorité signataire |
| `payload` | texte | Charge utile JSON de l'alerte |
| `severity` | entier | Niveau de sévérité |
| `title`, `body` | texte | Contenu affiché |
| `receivedAt` | date | Réception |
| `expiresAt` | date | Fin de validité |

### `settings` et `peers`

| Table | Colonnes | Rôle |
|:---|:---|:---|
| `settings` | `(key, value)` | Préférences typées en paires clé/valeur |
| `peers` | `id`, `transport`, `displayName`, `rssi`, `lastSeenAt` | Pairs récemment vus |

## 4. Index et pragma

Créés dans `onCreate` :

| Index | Colonnes | Pourquoi |
|:---|:---|:---|
| `idx_messages_channel_created` | `(channel_id, created_at)` | Historique d'un salon, déjà trié |
| `idx_outbox_due` | `(next_attempt_at, expires_at)` | Sélection des paquets à émettre |
| `idx_seen_expiry` | `(expires_at)` | Purge du cache de déduplication |
| `idx_alerts_expiry` | `(expires_at)` | Alertes actives |

Appliqués dans `beforeOpen` : `PRAGMA journal_mode=WAL` et `PRAGMA foreign_keys=ON`.

**Version de schéma : 1.** `MigrationStrategy` ne définit pour l'instant qu'un `onCreate` ; toute évolution du schéma exigera un `onUpgrade` et un bump de `schemaVersion`.

## 5. Cycle de vie et purge

| Élément | Règle |
|:---|:---|
| `messages` | 30 jours (`messageRetention`), purge au démarrage puis toutes les heures |
| `packets_outbox` | Supprimé après transmission ou à expiration |
| `seen_packets` | 7 jours (`seenPacketLifetime`) |
| `relay_receipts`, `delivery_acks` | Supprimés en cascade manuelle quand le message associé disparaît |
| `trusted_alerts` | Expirées mais conservées ; la purge n'est pas encore planifiée |

**Garantie.** Aucun message n'est supprimé tant qu'il est dans l'outbox et non expiré. La purge s'exécute dans une transaction unique, pour qu'un plantage ne laisse pas la base dans un état intermédiaire.
## 6. Identité et clé privée

- **Génération** : graine Ed25519 de 32 octets tirée par `Random.secure()`.
- **Stockage** : la graine est encodée en base64 et écrite dans `flutter_secure_storage` sous la clé `hafatra.identity.seed.v1`. Android la range dans le Keystore, chiffrée au repos.
- **Identifiant** : `SHA-256(clé publique)[0..8]` en hexadécimal — 16 caractères, stable, non révocable.
- **Profil** : le nom affiché et la date de création sont dans `identities`, pas dans le coffre.
- **Repli** : `InMemorySecretStore` permet de tester l'identité sans le plugin Android.

**Point de vigilance.** L'identifiant dérive de la clé publique : il est donc **dérivable par quiconque possède la clé publique**. Ce n'est pas un secret, mais il ne doit pas être traité comme un identifiant secret dans les journaux.

## 7. Le salon est public, et c'est assumé

- Le code de quartier est normalisé puis haché en SHA-256 (`codeHash`) ; les deux valeurs sont conservées pour permettre l'affichage du nom et la comparaison.
- **Aucun chiffrement de bout en bout du salon public.** Tout relais qui relaie un message peut en lire le contenu.
- L'interface et l'onboarding l'indiquent explicitement à l'utilisateur.
- La clé publique de l'expéditeur est **visible dans les paquets** : c'est le prix de la vérifiabilité.

## 8. Journalisation

### Rotation

- Fichier : `getApplicationSupportDirectory()/logs/hafatra.log`, seuil **512 Ko**, **1 archive** (`hafatra.log.1`).
- Tampon mémoire de **500 lignes**, alimenté par `onRecord` sur le logger `Hafatra`.
- `hierarchicalLoggingEnabled = true` est activé **avant** de régler le niveau : sans cela, la bibliothèque `logging` lève `UnsupportedError` au démarrage.
- Niveaux : `FINE` en debug, `INFO` en release.

### Ce qui ne doit jamais être journalisé

- Contenu d'un message.
- Clé privée ou graine.
- Nom complet ou localisation précise.
- Empreinte complète d'une clé : seules les empreintes **courtes** sont écrites (`ByteUtils.shortFingerprint`).

### Erreurs

Hiérarchie scellée dans `core/errors/app_exception.dart` :

```text
AppException
├── TransportException      (BLE indisponible, permission, connexion perdue)
├── StorageException        (base de données, migration, disque plein)
├── CryptoException         (signature invalide, clé absente)
├── ValidationException     (message vide ou trop long, salon invalide)
├── PermissionException     (refus utilisateur)
└── UnknownException
```

Les couches basses lancent des exceptions typées ; les repositories les traduisent. L'interface utilise `AsyncValue`, affiche un message générique localisé et propose une action (« Réessayer », « Ouvrir les réglages »). **Aucun `catch` silencieux** : les erreurs attendues sont loguées en `warning`, les inattendues en `error`.

**Amélioration identifiée.** Un `ErrorMapper` centralisé reste à créer pour la V1.1.
## 9. Cycle d'initialisation

```text
main()
  ├─ runZonedGuarded + FlutterError.onError + PlatformDispatcher.onError
  ├─ ouverture de la base (Drift, WAL)
  ├─ AppLogger (tampon mémoire + sink fichier)
  ├─ IdentityService.load()  → graine depuis le coffre, profil depuis la base
  ├─ ChannelService.load()   → salon de quartier local
  ├─ SettingsRepository.load() → langue, thème, relais, seuil de batterie
  └─ purge au démarrage + timer horaire
```

## 10. Paramètres applicatifs

| Clé | Valeur par défaut |
|:---|:---|
| `locale` | `fr` |
| `theme` | `system` |
| `relay_enabled` | `true` |
| `battery_threshold` | `15` (borné à 5–40) |
| `demo_mode` | `false` |
| `onboarding_complete` | `false` |

Le seuil de batterie est re-borné à la lecture : une valeur corrompue dans la base ne peut pas désactiver le relais de façon incontrôlée.

## 11. Ce que la V1 ne promet pas

- **Pas d'E2EE** pour le salon public. Le dire dans l'onboarding et dans l'interface.
- **Pas d'anonymat fort** : un relais voit les clés publiques, le canal et les horaires.
- **Pas de révocation d'autorité hors ligne** : les clés de confiance ont une période de validité.
- **Pas de protection contre un appareil compromis**.
- **Pas de chiffrement de la base locale** au-delà du stockage applicatif Android. SQLCipher est à l'étude pour la V2, si le besoin est confirmé.

## 12. Limites connues

| Limite | Impact | Statut |
|:---|:---|:---|
| `trusted_alerts` jamais purgées | Croissance lente de la base | À planifier |
| Pas de chiffrement SQLCipher | Base lisible en cas d'accès racine | V2 |
| `schemaVersion = 1` sans `onUpgrade` | Toute évolution du schéma exigera une migration | V1.1 |
| Pas d'export ni de sauvegarde de l'identité | Perte de clé = perte d'identité | Export prévu en V1.1 |
| Purge horaire non testée sur appareil | Rétention non confirmée en conditions réelles | Recette terrain |
