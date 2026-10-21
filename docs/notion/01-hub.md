# Hafatra

> 📡 **Messagerie hors-ligne multi-transport pour Madagascar.**
> Un quartier dense échange des messages et reçoit des alertes signées **sans Internet ni serveur**, en s'appuyant sur le Bluetooth Low Energy.

Hafatra permet à un quartier dense d'échanger des messages et de recevoir des alertes signées **sans Internet ni serveur**, en utilisant le Bluetooth Low Energy comme transport principal. La V1 livre le BLE réel, un transport simulé pour la démonstration et les tests, ainsi que les contrats nécessaires aux futurs transports.

## En bref

| Élément | Valeur |
| :--- | :--- |
| **Nom** | Hafatra |
| **Version** | 0.1.0+1 (V1) |
| **Package** | `mg.hafatra` (prototype) |
| **Plateforme** | Android 7.0+ (`minSdk 24`) — iOS hors périmètre |
| **Stack** | Flutter 3.47.5 / Dart 3.13.4 |
| **Langues** | Français par défaut, malgache disponible |
| **Transport principal** | Bluetooth Low Energy (central + périphérique) |
| **Modèle** | Flooding contrôlé, TTL 7, déduplication, store-and-forward |
| **Serveur** | Aucun — principe de souveraineté et de fonctionnement hors-ligne |
| **Dépendances clés** | `bluetooth_low_energy`, `drift`, `flutter_riverpod`, `go_router`, `flutter_foreground_task` |

## État vérifié au 2026-10-21

| Porte de qualité | Résultat |
| :--- | :--- |
| `flutter analyze` | ✅ **No issues found!** — 0 erreur, 0 avertissement |
| `flutter test` | ✅ **25/25 verts** |
| `flutter build apk --debug` | ✅ APK produit (`build/app/outputs/flutter-apk/app-debug.apk`) |
| `dart format --set-exit-if-changed` | ✅ Aucun changement |
| BLE réel / arrière-plan / batterie | ⏳ Non validés — exigent **2+ téléphones physiques** |
| Versionnement Git | ⚠️ Le dossier de travail **n'est pas un dépôt Git** |

## Ce que fait l'application

- **Salon de quartier** — un chat de groupe local, public par conception, qui fonctionne sans réseau.
- **Maillage** — chaque téléphone relaie les messages qu'il reçoit, avec un TTL borné et une déduplication par `messageId`.
- **Statut de livraison honnête** — l'UI dit la vérité : *En attente* → *Envoyé au réseau* → *Relayé par N* → *Vu par N*.
- **Alertes signées** — une autorité de confiance (Ed25519) signe les alertes cyclone/évacuation ; l'application refuse toute alerte non signée ou expirée.
- **Assistant anti-arrêt** — un guide qui aide à maintenir le relais actif sur les constructeurs qui tuent les applications en arrière-plan.
- **Diagnostic** — état BLE, service, batterie, permissions, journaux exportables, sans aucun envoi réseau.

## Documentation

Cette page est le point d'entrée. Chaque section est détaillée dans une page fille.

1. [Vision, périmètre et décisions](https://app.notion.com/p/400b224ccfa681f99afafde49e02bbf1) — le problème, le public cible, les arbitrages D1–D7 validés
2. [Architecture technique](https://app.notion.com/p/400b224ccfa681d389bfcf62dc7c9549) — couches, structure des dossiers, orchestration, modules
3. [Protocole mesh et format binaire](https://app.notion.com/p/400b224ccfa6814f9039e830b5e00fa9) — enveloppe HFT1 signée, types de paquets, statut de livraison
4. [Alertes signées et autorités de confiance](https://app.notion.com/p/400b224ccfa68177bd57e0b2588f92ed) — modèle de menace, clés Ed25519, autorité de confiance, CLI
5. [Transport Bluetooth LE](https://app.notion.com/p/400b224ccfa681ce8ebfcd22750e715b) — profil GATT, fragmentation, temporisations, performance et batterie
6. [Interface, design system et expérience utilisateur](https://app.notion.com/p/400b224ccfa68116ae9cdf32389687f2) — palette, typographie, composants, i18n FR/MG
7. [Données, persistance et confidentialité](https://app.notion.com/p/400b224ccfa681b0a726f170934dfa2f) — schéma Drift, hiérarchie d'exceptions, logs rotatifs
8. [Tests, qualité et déploiement](https://app.notion.com/p/400b224ccfa68179b62df16f1b1ce218) — 25 tests, harnais, portes de qualité, publication
9. [Guide du développeur](https://app.notion.com/p/400b224ccfa681d2a341fcc1c8685d8a) — démarrage, commandes, conventions de code, arborescence
10. [Risques, feuille de route et points ouverts](https://app.notion.com/p/400b224ccfa681deb74bcb16369dde8f) — plan incrémental, risques, checklist, décisions en attente

## Principes directeurs

- **Hors-ligne d'abord.** Aucune fonctionnalité ne dépend d'un serveur. Pas d'analytics, pas de crash reporting distant.
- **Statut honnête.** Le statut « Livré » n'est jamais affiché sur la seule base d'un envoi local.
- **Transports interchangeables.** Le cœur ne dépend d'aucun transport : ajouter Wi-Fi Direct, son, QR, NFC ou LoRa ne demande pas de refonte.
- **Transparence sur les limites.** Le salon public est public par conception ; l'UI le dit. Pas de promesse d'E2EE avant les messages privés (V2).
- **Clés de production sous contrôle des partenaires.** Aucune autorité réelle n'est embarquée tant qu'un partenaire n'est pas signé.

## Limites assumées de la V1

- Le salon public **n'est pas** chiffré de bout en bout : tout relais peut lire les messages.
- Les messages privés, le QR, le son, le Wi-Fi Direct, le NFC, l'USB, le LoRa et les passerelles ne sont pas implémentés (interfaces réservées).
- Le statut « Livré » est réservé à la V2.
- Aucune clé de production : l'autorité embarquée est explicitement non officielle.
- L'icône launcher est encore celle de Flutter.

## Contact et gouvernance

- **Porteur du projet :** Narindra Ranjalahy
- **Dépôt de code :** dossier de travail local `Hafatra` (non versionné — à migrer vers Git)
- **Autorité d'alerte de démonstration :** « Autorité de démonstration (non officielle) » — à remplacer par une autorité réelle (protection civile, mairie, ONG) avant toute distribution publique
