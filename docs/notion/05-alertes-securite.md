# Alertes signées et autorités de confiance

> **Statut : parcours complet implémenté et testé, clé de démonstration uniquement.** Aucune clé de production n'est livrée. La gouvernance réelle (qui signe, comment) reste à définir avec un partenaire officiel.

## 1. Problème

Une alerte d'urgence (« cyclone dans 6 heures, évacuez la zone basse ») doit être **difficile à falsifier**. Sans mécanisme de signature, n'importe quel téléphone peut diffuser de fausses alertes et semer la panique — c'est un risque documenté du projet.

## 2. Principe

```text
Autorité de confiance (clé privée) ──signe──▶ alerte signée ──diffusée──▶ téléphone
                                                                      │
                                                        vérifie la signature
                                                        contre la clé publique
                                                        embarquée
```

- L'**autorité** possède une clé **privée**. Elle signe l'alerte. La clé privée ne quitte **jamais** l'outil hors application.
- Le **téléphone** ne connaît que la clé **publique**. Il vérifie la signature. Il ne peut rien émettre de crédible.
- La liste des clés publiques de confiance est un asset embarqué : `assets/trusted_authorities.json`.

**Le téléphone ne peut pas émettre d'alerte de confiance.** C'est le cœur du dispositif.

## 3. Format de l'alerte signée

Document JSON autonome, transporté dans la charge utile du paquet `alert`.

```json
{
  "authorityId": "demo-hafatra",
  "alertId": "cyclone-2026-10-21-toliara",
  "severity": "critical",
  "title": "Alerte cyclone — zone basse de Toliara",
  "body": "Déplacementez-vous vers le terrain de football avant 18h.",
  "area": "Toliara",
  "issuedAt": 1793000000000,
  "expiresAt": 1793010000000,
  "signature": "Base64 de la signature Ed25519 (64 octets)"
}
```

| Champ | Contrainte |
|:---|:---|
| `authorityId` | Non vide, ≤ 80 caractères |
| `alertId` | Non vide, ≤ 80 caractères |
| `severity` | `info`, `warning` ou `critical` |
| `title` | Non vide, ≤ 120 caractères |
| `body` | Non vide, ≤ 1 200 caractères |
| `area` | ≤ 120 caractères |
| `issuedAt` | Millisecondes UTC |
| `expiresAt` | Millisecondes UTC, strictement postérieur à `issuedAt` |
| `signature` | Base64, exactement 64 octets décodés |

**Sévérités.** `info` (0), `warning` (1), `critical` (2). Une sévérité inconnue se replie sur `info`, par prudence.

## 4. Octets canoniques

La signature porte sur une **représentation canonique** déterministe, identique dans l'application et dans la CLI. C'est ce qui garantit qu'un fichier signé par l'outil est accepté par l'application.

```text
JSON UTF-8, clés dans cet ordre exact :
authorityId, alertId, severity, title, body, area, issuedAt, expiresAt
```

- `severity` sérialisé sous forme de **texte** (`info`, `warning`, `critical`), jamais en nombre.
- `issuedAt` et `expiresAt` sérialisés en **millisecondes UTC**.
- Les champs sont nettoyés (trim) **avant** signature, donc le document stocké et le document vérifié sont identiques.

## 5. Règles de vérification

`AlertVerifier.verify()` — logique **pure**, sans dépendance Flutter ni base de données, réutilisée telle quelle par l'application et par la CLI.

| Ordre | Vérification | Motif du rejet |
|:---|:---|:---|
| 1 | L'autorité existe dans la liste de confiance | `unknownAuthority` |
| 2 | L'alerte a été émise pendant la période de validité de l'autorité | `invalidAuthorityPeriod` |
| 3 | L'alerte n'est pas expirée | `expired` |
| 4 | L'alerte n'est pas émise dans un futur lointain (tolérance **10 min**) | `issuedInFuture` |
| 5 | La signature Ed25519 est valide sur les octets canoniques | `invalidSignature` |
| 6 | Format du document conforme | `malformed` |

**Anti-rejeu.** Un `alertId` déjà stocké est refusé avec `replayed` : la vérification de signature est inutile si l'alerte a déjà été traitée.

**Tolérances temporelles.**

| Paramètre | Valeur | Rôle |
|:---|:---|:---|
| `alertFutureTolerance` | 10 min | Tolère un décalage d'horloge entre l'émetteur et le récepteur |
| `alertPastTolerance` | 7 jours | Fenêtre de conservation des alertes expirées |

## 6. Autorités de confiance

Une autorité est décrite par :

```json
{
  "id": "demo-hafatra",
  "name": "Autorité de démonstration (non officielle)",
  "publicKey": "19196bbc29c77166e968255467af1ac5fc40ebc445042dd5dd8b645ab6171f98",
  "validFrom": "2026-01-01T00:00:00.000Z",
  "validTo": "2036-01-01T00:00:00.000Z"
}
```

| Champ | Rôle |
|:---|:---|
| `id` | Identifiant référencé par l'alerte |
| `name` | Nom lisible, affiché dans l'interface |
| `publicKey` | 32 octets en hexadécimal |
| `validFrom` / `validTo` | Fenêtre de validité, en UTC |

**La période de validité est un mécanisme de révocation.** Une autorité compromise peut être retirée de la liste embarquée par une mise à jour de l'application, ou neutralisée en faisant expirer sa période. La révocation immédiate par liste de révocation est prévue en V2.

**Emplacement de la liste.** `assets/trusted_authorities.json`, chargé par `AssetTrustedAuthoritySource` avec un cache en mémoire. Une source statique existe pour les tests et la CLI.
## 7. L'outil de signature (`tool/alert_tool.dart`)

L'outil tourne **hors application** (`dart run tool/alert_tool.dart`). Il n'est jamais embarqué dans l'APK.

### Créer une autorité

```bash
dart run tool/alert_tool.dart init \
  --out tool/demo_authority.json \
  --authorities assets/trusted_authorities.json
```

Produit deux fichiers :
- `tool/demo_authority.json` : la **clé privée** (graine + clé publique), hors assets, avec un avertissement explicite.
- `assets/trusted_authorities.json` : la **clé publique**, embarquée dans l'application.

### Signer une alerte

```bash
dart run tool/alert_tool.dart sign \
  --key tool/demo_authority.json \
  --out assets/demo/demo_alert.json \
  --severity critical \
  --title "Alerte cyclone — zone basse" \
  --body "Déplacementez-vous vers le terrain de football avant 18h." \
  --area "Toliara"
```

### Vérifier une alerte

```bash
dart run tool/alert_tool.dart verify \
  --alert assets/demo/demo_alert.json \
  --authorities assets/trusted_authorities.json
```

Sortie en cas de succès : `Alerte valide : <identifiant> (<nom de l'autorité>)`. En cas d'échec : `Alerte refusée : <motif>` et un code de sortie non nul.

### Options

| Commande | Options |
|:---|:---|
| `init` | `--out`, `--authorities`, `--id`, `--name`, `--valid-from`, `--valid-to`, `--force` |
| `sign` | `--key`, `--out`, `--alert-id`, `--severity`, `--title`, `--body`, `--area`, `--issued`, `--expires` |
| `verify` | `--alert`, `--authorities`, `--now` |

`--now` permet de tester la vérification à un instant arbitraire : c'est ainsi que les cas « expirée » et « émise dans le futur » se simulent.

## 8. Traitement d'une alerte à la réception

```text
Paquet alert reçu
  → décodage du document JSON
  → AlertVerifier.verify()
      ├─ acceptée → déduplication par alertId
      │              ├─ nouveau → persistance + notification + bannière d'urgence
      │              └─ déjà vu  → rejet (replayed)
      └─ refusée → journalisation du motif, rien n'est affiché à l'utilisateur
```

**Règle importante.** Une alerte refusée n'est **jamais** présentée à l'utilisateur comme une alerte. Elle est journalisée avec son motif de rejet. Présenter une alerte non vérifiée reviendrait à neutraliser tout le dispositif.

**Notification.** Chaque alerte vérifiée déclenche une notification locale et un flux `verifiedAlerts` que l'interface écoute pour afficher la bannière d'urgence. L'écran d'alerte affiche un badge « vérifiée », l'autorité signataire, la période de validité et l'empreinte de la signature.

## 9. Exemple de fichier de démonstration

`assets/demo/demo_alert.json` contient une alerte de démonstration déjà signée. Elle permet de tester le parcours complet sans passer par la CLI.

**Aucune clé réelle n'est embarquée.** L'autorité `demo-hafatra` est explicitement nommée « Autorité de démonstration (non officielle) », et la clé privée correspondante vit dans `tool/demo_authority.json`, hors du répertoire `assets`.

## 10. Limites connues

| Limite | Impact | Statut |
|:---|:---|:---|
| Aucune autorité de production | Les alertes réelles ne sont pas émises | **Attendu** — décision D3 |
| Révocation par expiration uniquement | Une autorité compromise reste valide jusqu'à la fin de sa période | Prévu en V2 (liste de révocation) |
| Pas de chiffrement du contenu de l'alerte | L'alerte est lisible par les relais | Documenté |
| Clé de démonstration dans le dépôt | Acceptable pour la démo, interdit en production | À déplacer hors dépôt avant toute sortie |
| Pas de vérification du réseau de l'émetteur | Une clé volée peut signer de fausses alertes | Mitigé par la période de validité |

## 11. Feuille de route sécurité

**V1 (livré) :** signature Ed25519, liste d'autorités embarquée, périodes de validité, anti-rejeu, outil de signature hors APK, alerte de démonstration.

**V2 :** messages privés chiffrés de bout en bout, Secret Sender, liste de révocation d'autorités, rotation des clés d'autorité, export/import de l'identité et de son journal de messages.

**V3 :** intégration avec une autorité réelle (mairie, ministère, protection civile), diffusion d'alertes à très grande échelle, bornes relais fixes, chiffrement de la couche lien pour les transports sans couche de sécurité native.
