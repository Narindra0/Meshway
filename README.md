# Hafatra

Messagerie hors-ligne multi-transport pour Madagascar. Android 7+ (`minSdk 24`), français par défaut,
malgache disponible.

Hafatra permet à un quartier dense d'échanger des messages et de recevoir des alertes signées **sans
Internet ni serveur**, en utilisant le Bluetooth Low Energy comme transport principal. La V1 livre le
BLE réel, un transport simulé pour la démonstration et les tests, ainsi que les contrats nécessaires
aux futurs transports.

## État

- `flutter analyze` : aucune erreur, aucun avertissement.
- `flutter test` : 25/25 verts (crypto, codec, alertes, onboarding).
- `flutter build apk --debug` : réussi.
- **Non encore validé :** BLE réel, service d'arrière-plan et consommation batterie sur téléphones
  physiques. Voir la recette terrain dans [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Démarrage

```bash
flutter pub get
flutter run
flutter test
flutter build apk --debug
```

L'APK debug est produit dans `build/app/outputs/flutter-apk/app-debug.apk`.

Au premier lancement : choisir un nom, un quartier, la langue, puis activer éventuellement le
**mode démo**. Le mode démo simule trois pairs, leurs accusés de réception et une alerte signée, sans
demander les permissions Bluetooth.

## Alertes signées

Les alertes sont vérifiées avec une autorité de confiance embarquée. Une autorité et une alerte de
démonstration sont fournies :

```bash
# Vérifier l'alerte livrée
dart run tool/alert_tool.dart verify \
  --alert assets/demo/demo_alert.json \
  --authorities assets/trusted_authorities.json

# Générer une nouvelle autorité de démonstration (hors APK)
dart run tool/alert_tool.dart init \
  --out tool/demo_authority.json \
  --authorities assets/trusted_authorities.json

# Signer une alerte
dart run tool/alert_tool.dart sign \
  --key tool/demo_authority.json \
  --out assets/demo/demo_alert.json \
  --severity warning \
  --title "Titre" --body "Message" --area "Quartier"
```

`tool/demo_authority.json` contient une clé privée de démonstration : elle ne doit **jamais** être
embarquée dans l'APK ni utilisée pour des alertes réelles. Voir
[`ARCHITECTURE.md`](ARCHITECTURE.md) §7.4.

## Limites de la V1

- Le salon public n'est **pas** chiffré de bout en bout : tout relais peut lire les messages.
- Les messages privés, le QR, le son, le Wi-Fi Direct, le NFC, l'USB, le LoRa et les passerelles ne
  sont pas implémentés.
- Le statut « Livré » est réservé à la V2 ; l'UI affiche « En attente », « Envoyé au réseau »,
  « Relayé par N » et « Vu par N ».
- Aucune clé de production n'est fournie ; l'autorité de démonstration est explicitement non
  officielle.
- L'icône launcher est encore celle de Flutter.

## Documentation

- [`ARCHITECTURE.md`](ARCHITECTURE.md) : décisions, protocole, BLE, sécurité, design, tests et recette.
- [`Messagerie_hors-ligne_document_de_reflexion.md`](Messagerie_hors-ligne_document_de_reflexion.md) :
  vision fonctionnelle d'origine.
- **Centre de documentation Notion (privé)** :
  <https://app.notion.com/p/400b224ccfa681ec9ab7d83a4a38ce60> — hub « Hafatra — Centre de
  documentation » et ses 10 pages filles (vision, architecture, protocole, alertes signées, BLE,
  UX, données, tests, guide développeur, feuille de route).
  Les sources Markdown de ces pages sont dans [`docs/notion/`](docs/notion/) ; la publication et la
  vérification se font avec [`tool/notion/`](tool/notion/).
  Le jeton d'accès Notion n'est jamais versionné : il s'obtient avec
  `.\tool\notion\get-token.ps1` et reste dans `.notion-oauth/` (ignoré par Git).
