# Interface, design system et expérience utilisateur

> **Statut : design system et écrans V1 livrés**, en français et en malgache. Les détails d'interface n'ont pas été validés sur appareil.

## 1. Principes de conception

1. **Le statut est un contenu, pas un détail.** Hors-ligne, un message n'est pas « envoyé » ou « échoué » : il est *en attente*, *envoyé au réseau*, *relayé par N appareils*, *vu par N*. L'utilisateur comprend que son message voyage.
2. **Priorité à l'urgence.** Une alerte signée traverse toute l'interface : bannière, notification, badge d'onglet, entrée dans le journal.
3. **Lisible sous le soleil.** Fonds clairs à fort contraste, typographie généreuse, pas d'informations uniquement portées par la couleur.
4. **Peu de mots, mots clairs.** Les textes sont en français par défaut, malgache disponibles. Les libellés de l'interface ne dépendent pas de termes techniques comme « TTL » ou « ACK ».
5. **Densité d'abord, décoration ensuite.** L'interface doit rester lisible sur un téléphone d'entrée de gamme à faible résolution.

## 2. Palette

**Teal profond** (confiance, marque), **ambre** (visibilité, attention), **corail** (urgence).

### Marques — thème clair

| Token | Valeur | Usage |
|:---|:---|:---|
| `primary` | `#0B4F4A` | Actions principales, barre de navigation |
| `primaryDeep` | `#06332F` | Fond des dégradés de marque |
| `primaryBright` | `#13796E` | Accent, dégradés |
| `primaryContainer` | `#CFE8E2` | Fonds des conteneurs selected |
| `secondary` | `#8A5A00` | Actions secondaires, badges |
| `secondaryContainer` | `#FFE2A8` | Fonds de badge ambre |
| `tertiary` | `#C73E1D` | Alerte critique, corail |
| `success` | `#2E7D32` | Confirmation |
| `warning` | `#B26A00` | Avertissement |
| `error` | `#B3261E` | Erreur |

### Surfaces — thème clair

Rampes de papier chaud, du plus haut au plus bas. Cinq niveaux par thème, pour que les cartes, les bulles et la barre de composition se distinguent **sans bordure**.

| Token | Valeur |
|:---|:---|
| `surfaceLowest` | `#FFFEFB` |
| `surfaceContainer` | `#FFFFFF` |
| `surfaceLow` | `#F5F3EC` |
| `surface` | `#EFEEE6` |
| `surfaceHigh` | `#E8E6DC` |
| `surfaceHighest` | `#DFDCD1` |

### Encre et contours

| Token | Clair | Sombre |
|:---|:---|:---|
| `ink` | `#141C1A` | `#E6EFEC` |
| `inkMuted` | `#4E5C58` | `#A3B2AD` |
| `outline` | `#6F7B78` | `#8A9692` |

### Surfaces — thème sombre

| Token | Valeur |
|:---|:---|
| `darkSurfaceLowest` | `#05100E` |
| `darkSurfaceLow` | `#0A1614` |
| `darkSurface` | `#101D1A` |
| `darkSurfaceHigh` | `#172623` |
| `darkSurfaceHighest` | `#1F312D` |

**Encre teintée teal** plutôt que gris pur : le thème sombre reste cohérent avec l'identité sans virer au bleu.
## 3. Extensions de thème

Au-delà du `ColorScheme`, deux extensions portent la identité visuelle :

- **`AppSurfaces`** : filets, ombres, lueurs — les valeurs fines du thème sombre.
- **`AppGradients`** : `brand`, `brandSoft`, `hero`, `sheen`, plus une encre dédiée `brandInk`.

**Point de vigilance.** `AppGradients.brandInk` est fixe dans les deux thèmes (`#F2FBF8` en clair, `#EAFBF6` en sombre). Utiliser `scheme.onPrimary` poserait un problème : cette valeur s'inverse en thème sombre et rendrait le texte illisible sur le dégradé `brand`, qui reste teal foncé dans les deux thèmes.

## 4. Navigation

Quatre onglets, un `StatefulShellRoute.indexedStack` : chaque onglet conserve sa pile de navigation.

| Onglet | Route | Contenu |
|:---|:---|:---|
| **Discussion** | `/chat` | Salon de quartier public |
| **Alertes** | `/alerts` | Liste des alertes, détail par alerte |
| **Maillage** | `/mesh` | État du relais, pairs, file d'attente |
| **Réglages** | `/settings` | Langue, thème, relais, batterie, permissions |

Écrans hors onglets : `/onboarding`, `/diagnostics`, `/about`.

**Redirection.** Tant que l'onboarding n'est pas terminé, toute route redirige vers `/onboarding`. Une fois terminé, `/onboarding` redirige vers `/chat`.

## 5. Onboarding

Cinq étapes, dans cet ordre :

1. **Bienvenue** — présentation de l'application et de la promesse hors-ligne.
2. **Langue** — français ou malgache. Le changement s'applique immédiatement.
3. **Identité** — choix du nom affiché (40 caractères maximum) et du code de quartier (3 à 32 caractères, `HAFATRA` par défaut).
4. **Permissions** — Bluetooth, notifications, batterie : explication de l'usage de chacune avant la demande système.
5. **Prêt** — activation du relais et résumé.

**Règle.** L'application ne bloque pas sur une permission refusée : elle explique, propose de réessayer, et fonctionne en mode dégradé (par exemple, relais désactivé mais lecture possible).

## 6. Salon de discussion

- **Salon public unique** par code de quartier. Pas de liste de contacts : tout le monde dans le quartier partage le même salon.
- **Bulles** : les messages sortants sont alignés à droite sur dégradé de marque, les entrants à gauche sur surface neutre. L'auteur n'est affiché que sur les messages entrants.
- **Badge de statut** sous chaque bulle sortante, avec une icône et un texte court.
- **Barre de composition** : champ multi-ligne, bouton d'envoi désactivé si le texte est vide ou dépasse 512 octets UTF-8, avec un compteur qui apparaît à l'approche de la limite.
- **Bannière de réseau** en haut : nombre de pairs connectés et dernière activité, pour que l'utilisateur sache si le salon est vivant.

### Les statuts de message

| Statut | Signification affichée |
|:---|:---|
| `queued` | En attente |
| `sent` | Envoyé au réseau |
| `relayed` | Relayé par N appareils |
| `seen` | Vu par N |
| `delivered` | Livré (réservé à la V2) |
## 7. Écran Maillage

Affiche en temps réel :

- **État du relais** : actif / arrêté / permission manquante.
- **Nombre de pairs** connectés.
- **File d'attente** : nombre de paquets en attente et oldest age.
- **Compteurs** : messages envoyés, reçus, relayés, paquets rejetés.
- **Batterie** : niveau, seuil de relais, état de charge.
- **Mode démonstration** : activable depuis les réglages pour faire tourner un pair virtuel.
- **Diagnostics** : accès aux journaux et à l'export.

## 8. Écran Alertes

- **Bannière d'urgence** en haut de l'écran, avec couleur selon la sévérité.
- **Liste** des alertes reçues, triées par date, avec badge de sévérité.
- **Détail** : titre, corps, zone, autorité signataire, période de validité, empreinte de la signature, badge « vérifiée ».
- **Filtres** : toutes / en cours / expirées.

**Sécurité d'affichage.** Seules les alertes **vérifiées** apparaissent. Une alerte refusée est journalisée mais jamais montrée.

## 9. Réglages

| Section | Contenu |
|:---|:---|
| **Général** | Langue (français/malgache), thème (clair/sombre/système) |
| **Réseau** | Relais activé ou non, seuil de batterie (5 à 40 %, 15 % par défaut) |
| **Mode démonstration** | Activation du pair virtuel simulé |
| **Permissions** | État de chaque permission, bouton pour rouvrir les réglages système |
| **À propos** | Version, identifiant de l'application `mg.hafatra`, limites connues de la V1 |

## 10. Internationalisation

- **Langues** : français (`fr`) par défaut, malgache (`mg`) disponible.
- **Fichiers** : `lib/l10n/arb/app_fr.arb` (modèle) et `lib/l10n/arb/app_mg.arb`, code généré dans `lib/l10n/generated/`.
- **Repli** : `context.l10n` retourne la chaîne Material ou Cupertino si la clé est absente, ce qui évite un écran vide plutôt qu'une erreur.
- **Format** : dates et nombres via `intl`.

## 11. Accessibilité

- **Contrastes** : le texte principal (`ink`) sur `surface` et sur les conteneurs respecte un rapport élevé ; `inkMuted` reste lisible mais réservé aux métadonnées.
- **Cible tactile** : 48 dp minimum pour les actions principales.
- **Ne pas compter sur la seule couleur** : chaque statut combine une icône et un texte.
- **Taille de police système** : respectée, aucun texte tronqué par une hauteur fixe.
- **Lecteurs d'écran** : `Semantics` sur les badges de statut et les indicateurs de relais.

## 12. Limites connues

| Limite | Impact | Statut |
|:---|:---|:---|
| Icône launcher par défaut de Flutter | Identité visuelle non finalisée | **À corriger** |
| Interface non validée sur appareil | Lisibilité réelle non confirmée | Recette terrain |
| Pas de message privé | Pas de conversation individuelle | V2 |
| Pas de pièce jointe | Texte uniquement | V2 |
| Salon unique sans contacts | Pas de conversation ciblée | V2 |
| Thème sombre peu testé | Risque de contraste insuffisant | À vérifier |
