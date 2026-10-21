# Vision, périmètre et décisions

> **Phrase de positionnement.** « La messagerie qui marche quand le réseau tombe, pensée pour les cyclones, les coupures et les téléphones de chez nous. »

## 1. Le problème

Quand le réseau tombe — cyclone, délestage, zone sans couverture — ou que la data est trop chère, les gens ne peuvent plus communiquer.

**Idée de départ.** Une application de messagerie hors-ligne qui transmet les messages sans Internet ni réseau cellulaire, d'abord par Bluetooth, avec des relais en réseau maillé (mesh) pour que deux utilisateurs éloignés puissent quand même s'écrire.

## 2. Ce qui existe déjà

| Solution | Technologie | Point fort | Point faible |
|:---|:---|:---|:---|
| Bridgefy | Bluetooth mesh | Grand public, connu | Failles de sécurité par le passé |
| Briar | Bluetooth, Wi-Fi, Tor | Très sécurisé | Surtout Android, orienté activistes |
| Bitchat | Bluetooth mesh | Minimaliste et récent | Peu de fonctions, peu de contexte local |
| Berty | Messagerie pair à pair | Décentralisé | Complexe pour le grand public |
| Meshtastic | LoRa | Longue portée (km) | Matériel dédié obligatoire |

**Constat.** Aucune de ces solutions n'est pensée pour Madagascar : ni interface en malgache, ni optimisation pour les téléphones d'entrée de gamme, ni mode cyclone, ni mélange de plusieurs moyens de transmission.

## 3. Ce qui rend Hafatra unique

### 3.1 Un système multi-transport

Le cœur du programme — chiffrement, file de messages, routage, statut de livraison — reste identique, et chaque moyen de transmission est un module interchangeable. L'application utilise ce qui est disponible à l'instant.

- **Bluetooth** pour le quotidien et le maillage de quartier.
- **Wi-Fi Direct** pour les transferts plus lourds à courte distance.
- **Son (ultrasons ou audible)** en secours et pour l'échange de contacts.
- **Son sur radio (talkie-walkie, VHF/UHF)** pour relier un village isolé sur plusieurs kilomètres.
- **QR code** pour l'échange de clés en face à face.
- **Passerelles opportunistes** : dès qu'un appareil retrouve Internet ou le SMS, il livre les messages vers l'extérieur.

### 3.2 Un statut de livraison honnête

Les messages hors-ligne ne sont pas instantanés. Plutôt que de faire croire le contraire, l'application affiche la réalité : *en attente*, *envoyé au réseau*, *relayé par N appareils*, *vu par N*. L'utilisateur comprend que son message voyage.

### 3.3 Un mode urgence pensé pour Madagascar

- Diffusion d'**alertes signées** (cyclone, évacuation) par une autorité de confiance, impossibles à falsifier.
- Bouton « **Je suis en sécurité** » — **reporté en V2** (décision D5), pour éviter la diffusion publique de l'état des personnes.
- Les messages d'urgence passent en **priorité** dans la file de relais.
### 3.4 Des bornes relais fixes à bas coût

Le réseau ne doit pas dépendre uniquement des gens qui se déplacent. De petits relais fixes (ESP32 ou module LoRa) chez un commerçant, une école ou une mairie gardent le réseau actif même quand personne ne bouge. **Prévu en V3.**

### 3.5 Un relais intelligent et économe

- Le relais s'adapte à la **batterie** : sous un seuil, l'appareil arrête de relayer.
- Routage adaptatif pour éviter la saturation dans les zones denses.
- Un **assistant de survie en arrière-plan** qui guide l'utilisateur pour maintenir le relais actif.

## 4. Les transports envisagés

| Transport | Portée | Débit | Avantage | Limite |
|:---|:---|:---|:---|:---|
| Bluetooth LE | 10 à 100 m | faible | Présent partout, économe | Restrictions iOS, arrière-plan Android |
| Wi-Fi Direct / Aware | 50 à 200 m | élevé | Transferts lourds | Plus gourmand en batterie |
| Son (ggwave) | quelques mètres | très faible | Marche sur tout téléphone, aucune permission réseau | Sensible au bruit, texte court seulement |
| Son sur radio | plusieurs km | très faible | Utilise du matériel déjà répandu | Nécessite une radio et un point relais |
| NFC | quelques cm | faible | Échange de clés fiable | Contact physique |
| QR code / flash + caméra | 1 à 10 m | très faible | Aucune radio nécessaire | Manuel, lent |
| USB OTG (câble) | contact | élevé | Transfert physique de messages | Peu pratique |
| LoRa (module externe) | plusieurs km | faible | Longue distance | Matériel dédié |

**Note sur les écouteurs.** Le haut-parleur et le micro du téléphone suffisent pour le transport par le son : les écouteurs n'apportent pas grand-chose. L'intérêt du son est surtout de servir de modem sur un canal audio existant comme une radio.

## 5. Fonctionnement du réseau

- **Flooding contrôlé** : chaque appareil retransmet les messages reçus, avec un TTL borné et un identifiant unique pour éviter les boucles.
- **Store-and-forward** : si personne n'est à portée, le message reste en base et voyage avec les gens jusqu'à croiser le destinataire.
- **Routage plus malin** (Spray and Wait, PRoPHET) pour limiter la saturation quand le réseau grandit — **réservé à la V2**, après mesures de densité.
- **Densité critique** : un mesh fonctionne dans un marché, une université ou un quartier dense, mais mal en zone rurale. D'où l'intérêt des bornes fixes et du son sur radio.
## 6. Les décisions validées (D1–D7)

Ces arbitrages ont été validés avec le porteur du projet **avant** l'écriture du code.

| ID | Sujet | Décision validée | Conséquence |
|:---|:---|:---|:---|
| **D1** | Périmètre | Architecture multi-transport, avec BLE réel + transport simulé fonctionnels. Les autres transports (Wi-Fi Direct, son, QR, NFC, USB, LoRa, passerelles) sont des contrats et des emplacements prévus, **pas des fonctionnalités livrées**. | Le cœur ne dépend d'aucun transport ; ajouter un transport ne demande pas de refonte. |
| **D2** | Transport Bluetooth | Vraie implémentation BLE (central + périphérique) derrière `MeshTransport`, plus un transport simulé pour les tests. Service de premier plan Android. | Le BLE devra être validé sur deux téléphones physiques ; le transport simulé couvre les tests automatisés. |
| **D3** | Alertes signées | Clé d'autorité de démonstration + liste de clés publiques de confiance importable + outil CLI de signature hors APK. **Aucune clé de production** sans partenaire. | Le parcours complet est testable ; la gouvernance réelle reste à signer. |
| **D4** | Nom et langue | Nom **Hafatra**, interface en **français par défaut**, malgache disponible via le sélecteur et les réglages. | Les ARB français et malgache sont livrés dès la V1. |
| **D5** | « Je suis en sécurité » | **Reporté en V2**, après les messages privés chiffrés. | Pas de diffusion publique de l'état des personnes en V1. |
| **D6** | Cible matérielle | Android 7.0+ (`minSdk 24`), téléphones d'entrée de gamme, APK par ABI. iOS hors périmètre. | Le service Android et le BLE sont les cibles de validation. |
| **D7** | Public pilote | **Quartier dense** (marché, université, quartier), 15 à 30 téléphones proches. | L'UX privilégie le salon public, la proximité et la clarté du statut. |

## 7. Périmètre exact de la V1

**Livré :**

- Le cœur multi-transport et le salon de quartier public.
- Le flooding avec TTL + déduplication, et le statut de livraison honnête.
- Le BLE réel (central + périphérique) et le transport simulé.
- Les alertes signées de démonstration et l'assistant d'arrière-plan.
- L'interface français/malgache, le design system, la persistance Drift.

**Non implémenté** (interfaces réservées) : messages privés, QR code, transport par le son, Wi-Fi Direct, NFC, USB, LoRa, passerelles Internet/SMS, bornes relais fixes, routage adaptatif.

## 8. Limites assumées de la V1

- Le salon public **n'est pas** chiffré de bout en bout : tout relais peut lire les messages.
- Le statut « Livré » est réservé à la V2 (messages privés).
- Aucune clé de production : l'autorité embarquée est explicitement non officielle.
- L'icône launcher est encore celle de Flutter.
- Le BLE réel, l'arrière-plan et la consommation batterie ne sont validés qu'en recette terrain.

## 9. Risques identifiés

1. **Densité insuffisante d'utilisateurs** : sans eux, le réseau ne sert à rien. Cible : un lieu ou une communauté dense.
2. **iOS** : le Bluetooth en arrière-plan y est très limité. Android d'abord.
3. **Constructeurs Android** qui tuent les applications en arrière-plan.
4. **Débit faible** : texte seul au départ, pas d'images ni de voix.
5. **Batterie** : scan et advertising continus à doser.
6. **Sécurité et métadonnées** : un relais voit qui passe à proximité.
7. **Usage abusif** : spam, fausses alertes. Les alertes doivent être signées.
8. **Légal et réglementaire** : usage des radios (fréquences, licences) et diffusion d'alertes officielles à vérifier localement.
9. **Adoption** : une messagerie n'a de valeur que si les gens l'installent.
