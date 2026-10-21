# Risques, feuille de route et points ouverts

> **Statut : la V1 est un prototype complet et compilable.** Le produit n'est pas validé sur téléphone physique, et cette page liste ce qui reste entre le prototype et un déploiement réel.

## 1. Risques et parades

| Risque | Gravité | Parade |
|:---|:---:|:---|
| BLE non validable sans téléphone physique | Élevée | Transport simulé dès l'étape 3 ; recette terrain planifiée ; ne pas déclarer « prêt » avant tests réels |
| Constructeurs qui tuent le service | Élevée | Assistant anti-arrêt, guide par marque, test réel, repli « relais seulement quand l'app est ouverte » |
| Android 14/15 : restrictions de service de premier plan | Élevée | Type `connectedDevice`, permissions explicites, test sur API 34/35, documentation Play |
| Densité insuffisante | Élevée (produit) | Pilote dans un lieu dense ; bornes fixes en V3 ; ne pas promettre une couverture rurale |
| Salon public lu par tous | Moyenne | Information claire dans l'interface ; E2EE réservé aux messages privés en V2 |
| Spam / flood | Moyenne | Rate limit, TTL, déduplication, blocage local d'un expéditeur |
| Batterie | Moyenne | Politique de seuils, mode économie, mesures |
| Clé d'alerte compromise | Élevée | Durée de validité courte, clés de confiance, procédure de rotation hors ligne |
| APK trop lourd | Moyenne | Une seule police embarquée (Inter variable sous-ensemblée, 250 Ko), pas d'images lourdes, split-per-ABI, obfuscation, mesures |
| Conflit de licence Android | Faible | Build debug réussi ; licences restantes à accepter pour le release ; épinglage `permission_handler` documenté |

## 2. Plan de développement

| Étape | Livrable | État |
|:---:|:---|:---|
| **0** | Projet Flutter, lints, thème, i18n, structure, CI locale | **Fait** — analyse sans erreur, format propre |
| **1** | Identité Ed25519, onboarding, stockage sécurisé, base Drift | **Fait** — tests crypto + widget onboarding |
| **2** | Salon de quartier, stockage local, interface, statuts, réglages de base | **Fait** — interface et streams Drift en place |
| **3** | Codec, signatures, `MeshEngine`, transport simulé multi-nœuds | **Partiel** — codec et moteur testés ; test d'intégration multi-nœuds à écrire |
| **4** | BLE central/périphérique, permissions, service de premier plan, assistant anti-arrêt | **Code écrit, APK debug construit** — validation BLE et arrière-plan en attente |
| **5** | Alertes signées, clés de confiance, CLI de signature, bannière | **Fait** — CLI, assets de démo, vérificateur testé |
| **6** | Durcissement, purge, performances, accessibilité, APK release | **À faire** — après recette BLE |

Chaque étape se termine par : code formaté, analyse sans erreur, tests verts, mise à jour de la documentation et courte note de décision.
## 3. Feuille de route produit

### V1 — ce qui est livré

Salon public de quartier, maillage multi-sauts par BLE, relais avec politique de batterie, alertes signées et vérifiées, interface français/malgache, mode démonstration, écran de diagnostic.

### V1.1 — durcissement

- Test d'intégration multi-nœuds sur transport simulé (3 à 5 nœuds, propagation, doublons, coupure).
- Widget tests pour le chat, les alertes, les réglages et les diagnostics.
- `ErrorMapper` centralisé.
- Export et sauvegarde de l'identité, avec confirmation explicite.
- Migration Drift : première évolution du schéma (`schemaVersion` 2) avec `onUpgrade` et test de migration.
- Purge planifiée des alertes expirées.
- Mesure de la couverture (`flutter test --coverage`) et atteinte de la cible de 80 % sur `domain/` et `mesh/`.

### V2 — confidentialité et usage

- **Messages privés** entre deux appareils, avec E2EE.
- Statut « Livré » (accusé de réception de bout en bout).
- Pièces jointes, avec une limite de taille et un transport par morceaux.
- Conversation ciblée, au-delà du salon public unique.
- « Je suis en sécurité » — point de contrôle reporté depuis la V1.
- Chiffrement de la base locale (SQLCipher), si le besoin est confirmé.
- Transport secondaire hors BLE, pour améliorer la portée.

### V3 — couverture et exploitation

- Bornes géographiques fixes pour le relais, en plus du TTL.
- Découverte de rôles et formation de paires, plutôt qu'une diffusion uniforme.
- Passerelle vers un réseau long distance, quand un réseau cyclable existe.
- Politique de localisation : uniquement les zones d'intérêt, jamais la position continue.
- Identité visuelle finale et publication.

## 4. Points encore ouverts

| # | Question | Impact |
|:---:|:---|:---|
| 1 | **Autorité réelle** : quelle organisation (protection civile, mairie, ONG) fournira la première clé publique de production ? | Seule la clé de démonstration est active. Bloquant pour un déploiement réel. |
| 2 | **Identifiant Play Store / nom de package** : `mg.hafatra` est un identifiant de prototype | Modifiable avant publication officielle |
| 3 | **Recette terrain** : les deux téléphones du porteur valideront le BLE, mais un test à 15–30 appareils dans un lieu dense reste nécessaire | Cible de crédibilité |
| 4 | **Licences Android et SDK 37** : le build debug fonctionne, mais les licences doivent être acceptées et l'épingle `permission_handler_android 13.0.1` levée quand l'outillage résoudra `android-37.0` | Bloquant pour le build release |
| 5 | **Design final** : la palette et la typographie sont définies ; logo, icône et captures restent à finaliser | L'icône launcher est encore celle de Flutter |
| 6 | **Seuil de batterie acceptable sur le terrain** : 15 % par défaut, à ajuster selon les mesures | Impact direct sur l'autonomie |
| 7 | **Politique de rétention** : 30 jours est un choix par défaut, non arbitré avec les utilisateurs | Impact sur la base locale |
## 5. Checklist de sortie

### Réalisé

- [x] Document de réflexion lu, périmètre, risques et questions ouvertes extraits.
- [x] Environnement Flutter / Dart / Android vérifié, limites de validation identifiées.
- [x] Packages sur pub.dev vérifiés : versions, maintenance, rôle.
- [x] Architecture, gestion d'état, persistance, transport et stratégie de test choisis.
- [x] Design system de base : couleurs, typographie, espacements, accessibilité.
- [x] Stratégie i18n malgache / français.
- [x] Stratégie d'erreurs et de journalisation.
- [x] D1 — périmètre : cœur multi-transport, BLE + simulation fonctionnels.
- [x] D2 — BLE réel + simulation, service de premier plan.
- [x] D3 — alertes de démo + clé importable + CLI.
- [x] D4 — Hafatra, français par défaut, malgache disponible.
- [x] D5 — « Je suis en sécurité » reporté en V2.
- [x] Identifiant d'application (`mg.hafatra`) et nom affiché (`Hafatra`) confirmés.
- [x] Socle, features, interface, routeur, CLI et assets de démonstration implémentés.
- [x] Tests écrits et passants (25/25) ; `flutter analyze` sans erreur.
- [x] APK debug construit (`build/app/outputs/flutter-apk/app-debug.apk`).

### Restant à faire

- [ ] Accepter les licences Android restantes (`flutter doctor --android-licenses`) pour le build release.
- [ ] Installer l'APK sur les téléphones et valider le BLE réel.
- [ ] Valider le service d'arrière-plan et la consommation batterie sur 2+ téléphones.
- [ ] Écrire le test d'intégration multi-nœuds sur transport simulé.
- [ ] Remplacer l'icône launcher Flutter par l'identité visuelle Hafatra.

## 6. Comment lire ce dépôt

| Document | Contenu |
|:---|:---|
| `README.md` | Point d'entrée : démarrage, état, commandes, limites |
| `ARCHITECTURE.md` | Décisions, protocole, BLE, sécurité, design, tests, recette |
| `Messagerie_hors-ligne_document_de_reflexion.md` | Vision fonctionnelle d'origine |
| `lib/` | Code applicatif, organisé par feature |
| `test/` | Tests automatisés et harnais |
| `tool/alert_tool.dart` | CLI de signature et de vérification des alertes |
