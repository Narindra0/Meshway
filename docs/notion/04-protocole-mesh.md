# Protocole mesh et format binaire

> **Version de protocole : 2.** En-tête binaire `HFT1`, 146 octets, signature Ed25519 sur les octets signés.
> Note de lecture : la **version 2 du protocole mesh** est distincte de la **version 1 du format de chunk BLE**. Elles ne bougent pas ensemble.

## 1. Vue d'ensemble

Un seul format binaire circule sur **tous** les transports. Le transport ne voit que des octets ; il ne connaît ni le chat, ni les alertes, ni l'interface.

```text
Émetteur
  └─ MeshPacket (enveloppe HFT1)
       └─ trame octets
            └─ Transport (BLE / simulé / futur)
                 └─ fragments selon le transport
```

**Principes.**

- **Signature d'intégrité et d'authentification** : Ed25519 sur les octets signés du paquet.
- **Débordement contrôlé** : TTL borné, compteur de sauts, identifiant unique par message.
- **Déduplication** : chaque `messageId` n'est traité qu'une fois par appareil.
- **Transport-agnostique** : aucun transport ne modifie le format du paquet.

## 2. En-tête du paquet HFT1

**Longueur totale de l'en-tête : 146 octets.**

| Décalage | Taille | Champ | Description |
|:---|:---|:---|:---|
| 0 | 4 | `magic` | `HFT1` (0x48 0x46 0x54 0x31) |
| 4 | 1 | `protocolVersion` | **2** |
| 5 | 1 | `type` | Type de paquet (voir §3) |
| 6 | 1 | `ttl` | TTL restant, 1 à 7 |
| 7 | 1 | `hopCount` | Nombre de sauts effectués, 0 à 15 |
| 8 | 2 | `payloadLength` | Longueur de la charge utile, uint16 big-endian |
| 10 | 16 | `messageId` | UUID v7 sur 16 octets |
| 26 | 8 | `channelId` | Identifiant de salon (8 octets) |
| 34 | 8 | `createdAt` | Horodatage UTC en millisecondes, uint64 big-endian |
| 42 | 8 | `senderId` | Les 8 premiers octets de SHA-256(clé publique) |
| 50 | 32 | `senderPublicKey` | Clé publique Ed25519 de l'expéditeur |
| 82 | 64 | `signature` | Signature Ed25519 (64 octets) |
| 146 | n | `payload` | Charge utile, ≤ 3 950 octets |

**Taille maximale d'un paquet : 4 096 octets.**

## 3. Types de paquets

| Valeur | Type | Rôle |
|:---|:---|:---|
| 1 | `chat` | Message de salon public |
| 2 | `alert` | Alerte d'urgence signée |
| 3 | `deliveryAck` | Accusé de réception |
| 4 | `relayReceipt` | Preuve qu'un relais a vu le message |
| 5 | `safety` | Message « Je suis en sécurité » (**reporté en V2**, décision D5) |
| 6 | `profile` | Profil public et empreinte de clé |

## 4. Octets signés

La signature ne couvre **ni** le TTL, **ni** le compteur de sauts, **ni** la signature elle-même. Les deux premiers changent à chaque relais ; le troisième est apposé après coup.

```text
magic (4)
+ protocolVersion (1)
+ type (1)
+ payloadLength (2)
+ messageId (16)
+ channelId (8)
+ createdAt (8)
+ senderId (8)
+ senderPublicKey (32)
+ payload (n)
```

**Conséquence.** Un relais peut corriger le TTL et incrémenter le nombre de sauts sans invalider la signature d'origine, mais il ne peut modifier ni le contenu, ni l'expéditeur, ni le canal, ni l'identifiant.

## 5. Identité et `senderId`

- `senderId` = **SHA-256(senderPublicKey)**, tronqué aux 8 premiers octets.
- C'est un identifiant **dérivé**, stable et non révocable : il ne dépend d'aucun annuaire.
- À la réception, le récepteur recalcule `senderId` et compare en **temps constant** (`ByteUtils.constantTimeEquals`) avec la valeur reçue. Une divergence ⇒ paquet rejeté.

## 6. Décodage et validation

`MeshPacketCodec.decode()` rejette le paquet si l'une de ces conditions n'est pas satisfaite :

1. Longueur inférieure à 146 octets ⇒ *Paquet trop court*.
2. Magic différent de `HFT1` ⇒ *Magic HFT1 absent*.
3. `protocolVersion` ≠ 2 ⇒ *Version de protocole inconnue*.
4. Type inconnu ⇒ *Type de paquet inconnu*.
5. `ttl` > 7 ou `hopCount` > 15 ⇒ *TTL ou nombre de sauts invalide*.
6. `payloadLength` > 3 950 ⇒ *Charge utile trop grande*.
7. Longueur réelle ≠ 146 + `payloadLength` ⇒ *Longueur de paquet incohérente*.
8. Horodatage nul ou postérieur à 2100 ⇒ *Horodatage de paquet invalide*.

`MeshPacketCodec.verify()` ajoute ensuite :

9. Longueurs de tous les champs conformes.
10. TTL et hopCount dans les limites.
11. `senderId` recalculé conforme (comparaison en temps constant).
12. Signature Ed25519 valide sur les octets signés.

**Règle de sécurité.** Le décodage et la vérification sont séparés : on ne fait jamais confiance au type de paquet avant d'avoir vérifié la signature.

## 7. Charge utile par type

### 7.1 `chat` — JSON UTF-8

```json
{ "n": "Aina", "t": "On se retrouve à la gare à 14h" }
```

- `n` : nom affiché, 1 à 40 caractères.
- `t` : texte du message, ≤ 512 octets UTF-8, non vide.

### 7.2 `deliveryAck` et `relayReceipt` — 17 octets binaires

```text
[0..15]  messageId (16 octets, format UUID canonique)
[16]     statut (deliveryAck) ou nombre de sauts (relayReceipt)
```

### 7.3 `alert` — charge utile opaque

Le paquet `alert` ne porte que l'identifiant de l'alerte et le canal. Le contenu signé est un document JSON autonome (voir la page « Alertes signées et autorités de confiance »), transporté en payload et vérifié indépendamment.
## 8. Fragmentation BLE

Le format de chunk BLE est **indépendant** de la version du protocole mesh. Un paquet HFT1 peut dépasser la MTU utile d'une écriture GATT : il faut donc le découper.

**Constantes du chunk.**

| Constante | Valeur | Rôle |
|:---|:---|:---|
| `bleChunkPayloadLength` | 176 | Charge utile maximale par chunk |
| `bleChunkHeaderLength` | 7 | Taille de l'en-tête de chunk |
| `bleChunkVersion` | 1 | Version du **format de chunk** (≠ version du protocole) |
| `bleMaxChunks` | 255 | Nombre maximal de chunks par transfert |

**En-tête de chunk (7 octets).**

| Décalage | Taille | Champ |
|:---|:---|:---|
| 0 | 1 | Version du chunk (1) |
| 1 | 2 | `transferId` (uint16) |
| 3 | 1 | Index du chunk |
| 4 | 1 | Nombre total de chunks |
| 5 | 2 | Longueur totale de la trame (uint16) |

**Réassemblage.** `BleChunkAssembler` suit les transferts par `transferId`, refuse les index invalides, les versions inconnues, les longueurs incohérentes, les chunks en double, les transferts trop longs ou incomplets, et n'émet une trame que lorsque tous les fragments sont reçus et que la longueur totale correspond exactement.

**Robustesse.** Un transfert abandonné laisse une entrée jusqu'au prochain `clear()`. Cette purge doit être branchée sur le cycle de vie de la connexion (voir « Risques et travaux à faire »).

## 9. Service GATT

Chaque téléphone expose **le même** service et les mêmes characteristics.

| Élément | UUID |
|:---|:---|
| Service | `51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0001` |
| `inbox` (écriture) | `51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0002` |
| `outbox` (lecture) | `51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0003` |

**Le nom d'appareil n'est pas diffusé** (`advertiseName = false`) : il ne tiendrait pas dans les 31 octets utiles du paquet d'advertising, et il n'est pas nécessaire.

## 10. Politiques réseau

### 10.1 TTL et sauts

- TTL par défaut : **7**. TTL maximum : 7. TTL minimum : 1.
- `hopCount` maximum : 15.
- Chaque relais décrémente le TTL avant de retransmettre.

### 10.2 Priorités

| Priorité | Valeur | Type |
|:---|:---|:---|
| `priorityAlert` | 100 | `alert` |
| `priorityAck` | 60 | `deliveryAck` |
| `priorityReceipt` | 40 | `relayReceipt` |
| `priorityChat` | 20 | `chat` |

Les paquets sont extraits de la file d'attente par priorité décroissante, puis par date de création.

### 10.3 Limitation de débit

`MeshRateLimiter` limite par expéditeur :

- **20 paquets par fenêtre d'une minute** (`rateLimitPerSenderPerMinute`).
- **Intervalle minimal de 2 secondes** entre deux paquets du même expéditeur (`rateLimitMinInterval`).

Les événements hors fenêtre sont purgés à chaque appel. Le but est de contenir les inondations locales sans bloquer la diffusion normale d'un salon animé.

### 10.4 Politique de relais et batterie

`RelayPolicy.shouldRelay()` décide si un paquet reçu peut être retransmis :

| Condition | Résultat |
|:---|:---|
| Relais désactivé par l'utilisateur | **Ne pas relayer** |
| Batterie critique (sous le seuil) et pas en charge | **Ne pas relayer** |
| Batterie faible (seuil ≤ 30 %) et pas en charge | Relayer **uniquement** `alert`, `deliveryAck`, `relayReceipt` |
| Sinon | Relayer |

**Intention.** En réserve, l'appareil continue de faire circuler l'essentiel (les alertes et les accusés) mais cesse de transporter la conversation. Un appareil en charge n'est jamais bridé par ce seuil.

### 10.5 Jitter et file d'attente

- Jitter maximal avant relais : **500 ms** (`relayJitterMax`) — évite que tous les relais retransmettent au même instant.
- Pompe de la file d'attente : toutes les **3 secondes** (`outboxPumpInterval`).

### 10.6 Déduplication

- Les `messageId` vus sont conservés **7 jours** (`dedupRetention`).
- Purge périodique des entrées expirées.

## 11. Cycle de vie d'un paquet

```text
1. Émission      MeshEngine construit le paquet, le signe, l'insert en outbox
2. Pump          toutes les 3 s, sélection par priorité puis ancienneté
3. Transport     découpe en chunks BLE (ou envoi direct en simulation)
4. Réception     réassemblage → décodage → vérification signature
5. Limitation   contrôle du débit par expéditeur
6. Déduplication messageId déjà vu ? → rejet silencieux
7. Persistance  enregistrement, puis émission vers l'UI
8. Relais       RelayPolicy + TTL - 1 + jitter → renvoi à un sous-ensemble de pairs
9. Accusés      deliveryAck (reçu) et relayReceipt (relayé) produits par les pairs
```

## 12. Ce que le protocole ne fait pas (volontairement)

- **Pas de chiffrement de bout en bout du contenu.** La signature garantit l'intégrité et l'origine, pas la confidentialité. Tout relais voit le texte.
- **Pas de Secret Sender.** Les messages privés sont prévus en V2.
- **Pas de routage adaptatif.** Le flooding est borné par TTL et déduplication ; Spray-and-Wait et PRoPHET sont en V2.
- **Pas de fragmentation multi-paquets.** Un message de salon tient dans un seul paquet (512 octets de texte). Les messages plus longs sont refusés au niveau du codec de payload.
- **Pas d'accusé de bout en bout fiable.** `deliveryAck` prouve qu'un pair a vu le message, pas qu'il est arrivé à son destinataire final.

## 13. Compatibilité et évolutions

- Un paquet dont `protocolVersion` ≠ 2 est **rejeté**, pas interprété. C'est un choix délibéré : mieux vaut refuser que mal interpréter.
- Le numéro de type de paquet est réservé par famille pour permettre l'ajout de types sans renuméroter.
- Ajouter un transport ne change **rien** au format du paquet : le transport ne fait que transporter des octets.
- La signature Ed25519 et SHA-256 sont utilisés via `cryptography_plus` (pur Dart), sans dépendance native.
