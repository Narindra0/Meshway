# Messagerie hors-ligne multi-transport : document de réflexion


Document de travail pour bien penser le programme avant de le construire : vision, idées pour le rendre unique, choix techniques, risques et plan d'action.

# 1. Vision

**Problème.** Quand le réseau tombe (cyclone, délestage, zone sans couverture) ou que la data est trop chère, les gens ne peuvent plus communiquer.

**Idée de départ.** Une application de messagerie hors-ligne qui transmet les messages sans Internet ni réseau cellulaire, d'abord par Bluetooth, avec des relais en réseau maillé (mesh) pour que deux utilisateurs éloignés puissent quand même s'écrire.

**Phrase de positionnement (à affiner).** « La messagerie qui marche quand le réseau tombe, pensée pour les cyclones, les coupures et les téléphones de chez nous. »

# 2. Ce qui existe déjà

| Solution | Technologie | Point fort | Point faible |
|:--------------|:--------------|:------------------|:------------------------|
| Bridgefy | Bluetooth mesh | Grand public, connu | Failles de sécurité par le passé |
| Briar | Bluetooth, Wi-Fi, Tor | Très sécurisé | Surtout Android, orienté activistes |
| Bitchat | Bluetooth mesh | Minimaliste et récent | Peu de fonctions, peu de contexte local |
| Berty | Messagerie pair à pair | Décentralisé | Complexe pour le grand public |
| Meshtastic | LoRa | Longue portée (km) | Matériel dédié obligatoire |

**Constat.** Aucune de ces solutions n'est pensée pour Madagascar : ni interface en malgache, ni optimisation pour les téléphones d'entrée de gamme, ni mode cyclone, ni mélange de plusieurs moyens de transmission.

# 3. Ce qui rendrait le projet unique

## 3.1 Un système multi-transport

L'application ne dépend pas d'une seule technologie. Le cœur du programme (chiffrement, file de messages, routage, statut de livraison) reste le même, et chaque moyen de transmission est un module interchangeable. L'application utilise ce qui est disponible à l'instant.

- **Bluetooth** pour le quotidien et le maillage de quartier.
- **Wi-Fi Direct** pour les transferts plus lourds à courte distance.
- **Son (ultrasons ou audible)** en secours et pour l'échange de contacts.
- **Son sur radio (talkie-walkie, VHF/UHF)** pour relier un village ou un quartier isolé sur plusieurs kilomètres.
- **QR code** pour l'échange de clés en face à face.
- **Passerelles opportunistes** : dès qu'un appareil retrouve Internet ou le SMS, il livre les messages vers l'extérieur.

## 3.2 Un statut de livraison honnête

Les messages hors-ligne ne sont pas instantanés. Plutôt que de faire croire le contraire, l'application affiche la réalité : *en attente, relayé par N appareils, livré*. L'utilisateur comprend que son message voyage.

## 3.3 Un mode urgence pensé pour Madagascar

- Diffusion d'**alertes signées** (cyclone, évacuation) par une autorité de confiance (protection civile, mairie), impossibles à falsifier.
- Bouton « **Je suis en sécurité** » qui prévient automatiquement les proches enregistrés dès que le message croise un relais.
- Les messages d'urgence passent en **priorité** dans la file de relais.

## 3.4 Des bornes relais fixes à bas coût

Le réseau ne doit pas dépendre uniquement des gens qui se déplacent. De petits relais fixes (ESP32 ou module LoRa) chez un commerçant, une école ou une mairie gardent le réseau actif même quand personne ne bouge.

## 3.5 Un relais intelligent et économe

- Le relais s'adapte à la **batterie** : sous un seuil, l'appareil arrête de relayer.
- Routage adaptatif pour éviter la saturation dans les zones denses (au lieu d'un simple flooding).
- Un **assistant de survie en arrière-plan** qui guide l'utilisateur pour empêcher Tecno, Infinix ou Xiaomi de fermer l'application. C'est un point où beaucoup d'applications échouent.

## 3.6 Une vie privée sérieuse

- Identités à base de **clés publiques**, sans numéro de téléphone.
- **Chiffrement de bout en bout** des messages privés.
- Identifiants Bluetooth qui **changent régulièrement** pour éviter le suivi d'une personne à la trace.
- Protection contre le spam et le flood.

## 3.7 Un produit local

- Interface en **malgache et en français**.
- APK très léger, adapté aux téléphones d'entrée de gamme.
- Partenariats avec des écoles, des ONG, la protection civile et des quartiers.

# 4. Les transports en détail

| Transport | Portée | Débit | Avantage | Limite |
|:------------|:----------|:--------|:---------------------|:---------------------|
| Bluetooth LE | 10 à 100 m | faible | Présent partout, économe | Restrictions iOS, arrière-plan Android |
| Wi-Fi Direct / Aware | 50 à 200 m | élevé | Transferts lourds | Plus gourmand en batterie |
| Son (ggwave) | quelques mètres | très faible | Marche sur tout téléphone, aucune permission réseau | Sensible au bruit, texte court seulement |
| Son sur radio | plusieurs km | très faible | Utilise du matériel déjà répandu | Nécessite une radio et un point relais |
| NFC | quelques cm | faible | Échange de clés fiable | Contact physique |
| QR code / flash + caméra | 1 à 10 m | très faible | Aucune radio nécessaire | Manuel, lent |
| USB OTG (câble) | contact | élevé | Transfert physique de messages | Peu pratique |
| LoRa (module externe) | plusieurs km | faible | Longue distance | Matériel dédié |

**Note sur les écouteurs.** Le haut-parleur et le micro du téléphone suffisent pour le transport par le son : les écouteurs n'apportent pas grand-chose. L'intérêt du son est surtout de servir de modem sur un canal audio existant comme une radio.

# 5. Fonctionnement du réseau

- **Flooding contrôlé** : chaque appareil retransmet les messages reçus, avec un TTL (nombre de sauts maximum, par exemple 5 à 7) et un identifiant unique pour éviter les boucles.
- **Store-and-forward** : si personne n'est à portée, le message reste en mémoire et voyage avec les gens jusqu'à croiser le destinataire.
- **Routage plus malin** (Spray and Wait, PRoPHET) pour limiter la saturation quand le réseau grandit.
- **Densité critique** : un mesh fonctionne dans un marché, une université, un quartier dense, mais mal en zone rurale. D'où l'intérêt des bornes fixes et du son sur radio.

# 6. Risques et obstacles

1. **Densité insuffisante** d'utilisateurs : sans eux, le réseau ne sert à rien. Il faut cibler d'abord un lieu ou une communauté dense.
2. **iOS** : le Bluetooth en arrière-plan est très limité. Android d'abord.
3. **Constructeurs Android** qui tuent les applications en arrière-plan.
4. **Débit faible** : texte seul au départ, pas d'images ni de voix.
5. **Batterie** : scan et advertising continus à doser.
6. **Sécurité et métadonnées** : un relais voit qui passe à proximité. Il faut y réfléchir dès la conception.
7. **Usage abusif** : spam, fausses alertes. Les alertes doivent être signées.
8. **Légal et réglementaire** : l'usage de radios (fréquences, licences) et la diffusion d'alertes officielles demandent à vérifier les règles locales.
9. **Adoption** : une messagerie n'a de valeur que si les gens l'installent. Il faut un cas d'usage clair et des partenaires.

# 7. Plan de MVP

**Version 1 : Android uniquement, texte seul.**

1. Salon de quartier public (chat de groupe local) en Bluetooth, plus simple à tester que la messagerie privée.
2. Flooding avec TTL et déduplication.
3. Statut de livraison honnête.
4. Assistant anti-arrêt en arrière-plan.
5. Alertes signées (mode urgence de base).
6. Test réel avec 15 à 30 téléphones dans un lieu dense.

**Version 2.**

- Messages privés chiffrés avec store-and-forward.
- Échange de contacts par QR code.
- Transport par le son (prototype ggwave).

**Version 3.**

- Wi-Fi Direct pour les transferts plus lourds.
- Bornes relais fixes.
- Son sur radio et passerelles vers Internet ou SMS.

# 8. Premiers tests à faire

- **Test ggwave** entre deux téléphones, dans une pièce calme puis dans un lieu bruyant, pour mesurer la fiabilité réelle du son.
- **Test Bluetooth** sur plusieurs marques de téléphones (Tecno, Infinix, Xiaomi, Samsung) pour voir lesquelles gardent le relais en arrière-plan.
- **Test de sauts** : combien de sauts tient un message dans un groupe de 15 à 30 téléphones ?
- **Test batterie** : consommation sur une journée avec le relais actif.

# 9. Questions ouvertes

- Quel est le **premier public cible** : étudiants, un quartier, une ville exposée aux cyclones, une organisation partenaire ?
- Quel **modèle économique** (gratuit avec partenaires, ONG, financement public, version payante pour les bornes) ?
- Quel **nom** pour le projet ?
- Quelles **fonctions** garder pour la V1 pour ne pas se disperser ?
- Qui fait quoi dans l'équipe (application Android, protocole réseau, sécurité, design, partenariats) ?
- Quelles autorités ou organisations pourraient signer les alertes ?

# 10. Prochaines étapes

- [ ] Valider le positionnement et le public cible
- [ ] Tester ggwave et le Bluetooth sur plusieurs téléphones
- [ ] Choisir les transports pour la V1
- [ ] Rédiger un cahier des charges détaillé
- [ ] Définir l'architecture technique (protocole, chiffrement, format des messages)
- [ ] Prototyper le salon de quartier
- [ ] Contacter un premier partenaire (école, ONG, protection civile)
