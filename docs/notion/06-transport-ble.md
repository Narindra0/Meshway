# Transport Bluetooth LE

> **Statut : implémenté, non validé sur appareil.** Le transport BLE existe dans le code mais n'a jamais été testé sur deux téléphones physiques. C'est le premier point de la recette terrain.

## 1. Rôle du transport

Le transport ne connaît **que** des octets. Il ne connaît ni le chat, ni les alertes, ni l'interface, ni la base de données. Il expose trois choses au cœur du mesh :

```text
MeshTransport
  ├─ start()          démarre la découverte et l'écoute
  ├─ stop()           arrête proprement
  ├─ send(frame)      envoie une trame HFT1
  └─ frames           flux d'octets reçus
```

**Conséquence.** Remplacer le BLE par un autre support (Wi-Fi, son, radio) ne demande que d'implémenter cette interface. Le cœur du protocole, lui, ne change pas.

## 2. Topologie

Hafatra utilise un modèle **point à point maillé**, pas un modèle « broadcaster » classique :

- Chaque téléphone se connecte à plusieurs pairs et **relaye** les paquets qu'il reçoit.
- Un appareil peut être à la fois **central** (il scanne et se connecte) et **périphérique** (il advertise et accepte des connexions).
- Le rôle n'est pas figé : la topologie se recompose en permanence selon la position et la disponibilité des appareils.

```text
   (A) ──── (B) ──── (C)
    │                   │
    └─────── (D) ──────┘
```

Un message de A vers C peut transiter par B ou D, ou par les deux. Le TTL borne la propagation.

## 3. Service GATT

| Élément | UUID | Rôle |
|:---|:---|:---|
| Service | `51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0001` | Service Hafatra |
| `inbox` | `51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0002` | Écriture : on y envoie les trames |
| `outbox` | `51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0003` | Lecture : on y reçoit les trames |

Les UUID sont identiques sur tous les appareils : il n'y a pas de « Hafatra nearby » à filtrer, tout appareil qui expose ce service est un pair potentiel.

**Le nom d'appareil n'est pas diffusé.** Le paquet d'advertising BLE ne laisse que 31 octets utiles, et le nom n'apporte rien au protocole. `advertiseName = false` est explicite dans le code.

## 4. Écriture et lecture

- **Écriture** vers `inbox` : la trame complète, ou fragmentée si elle dépasse la MTU utile.
- **Lecture** (notification) depuis `outbox` : les fragments reçus.

Le format des fragments est décrit dans la page « Protocole mesh et format binaire » (§8) : en-tête de 7 octets, charge utile de 176 octets, `transferId` sur 16 bits.

## 5. Temporisations

| Constante | Valeur | Rôle |
|:---|:---|:---|
| `bleConnectionTimeout` | 12 s | Délai maximal pour établir une connexion |
| `bleReconnectCooldown` | 8 s | Pause avant de retenter une connexion |
| `bleKeepAlive` | 20 s | Maintien de la connexion |

**Intention.** Un téléphone qui s'éloigne ne doit pas laisser le moteur dans un état ambigu : la connexion expire proprement, le pair est retiré, et la découverte reprend.

## 6. Cycle de vie

```text
start()
  ├─ vérifie les permissions Bluetooth (Android 12+ : BLUETOOTH_SCAN / CONNECT)
  ├─ démarre la découverte
  ├─ advertise en périphérique
  ├─ scan en central
  └─ connecte aux pairs trouvés, avec timeout et cooldown
stop()
  └─ ferme les connexions, arrête advertising et scan
```

**Gestion des erreurs.** Une erreur de permission est remontée à l'UI comme une `AppException` typée, avec un message localisé et une action (« Autoriser le Bluetooth »). Une erreur réseau BLE est journalisée et retentée selon le cooldown, jamais fatale pour le moteur.

## 7. Performance et batterie

Le scan BLE et l'advertising en continu sont les deux principaux postes de consommation. Les leviers utilisés en V1 :

- **Seuil de batterie** : passé sous le seuil défini par l'utilisateur, l'appareil cesse de relayer (voir `RelayPolicy`).
- **Relais désactivable** : l'utilisateur peut choisir de ne jamais relayer.
- **Jitter** : évite les rafales de retransmission synchronisées entre tous les pairs.
- **Fenêtre d'acknowledgement** : l'écriture GATT est confirmée avant de passer au chunk suivant.

## 8. Limites connues

| Limite | Impact | Statut |
|:---|:---|:---|
| BLE non testé sur appareil physique | Le comportement réel est inconnu | **Bloquant pour la recette** |
| Restrictions iOS en arrière-plan | BLE très limité sur iOS | Hors périmètre (décision D6) |
| Constructeurs Android qui tuent le service | Réseau qui s'arrête sans prévenir | À tester sur les marques courantes |
| MTU variable | La fragmentation doit s'adapter | Géré par le codec de chunk |
| `BleChunkAssembler` non purgé à la déconnexion | Fuite mémoire sur connexions instables | **À corriger** |
| Pas de chiffrement de la couche BLE | Un contenu peut être intercepté par un tiers proche | Documenté, non corrigé en V1 |

## 9. Recommandations pour la recette terrain

1. **Deux téléphones Android** minimum, ideally trois pour tester le relais.
2. Vérifier que le service de premier plan survit à l'extinction de l'écran et au verrouillage.
3. Mesurer la consommation sur **une heure** de scan continu avec le salon actif.
4. Tester la reprise après un kill du processus par le système.
5. Tester la connexion dans un environnement bruyant (marché) : c'est le cas d'usage réel.
6. Vérifier le comportement des deux versions d'Android (API 24 d'un côté, API 34+ de l'autre) : le comportement des permissions BLE diffère fortement.

## 10. Prochaines étapes

- Corriger la purge de `BleChunkAssembler` sur déconnexion et sur expiration de transfert.
- Documenter et stabiliser le contrat du transport, afin que les transports futurs (Wi-Fi, son) puisse être ajoutés sans modifier le cœur.
- Ajouter une mesure du débit réel et du nombre de pairs, exposée dans l'écran « Maillage ».
- Évaluer un chiffrement de la couche lien (au moins un chiffrement de session) avant toute sortie hors du quartier pilote.
