// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Hafatra';

  @override
  String get appTagline => 'La messagerie qui marche quand le réseau tombe.';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Hafatra';

  @override
  String get onboardingWelcomeBody =>
      'Écrivez aux personnes autour de vous, même sans Internet et sans crédit.';

  @override
  String get onboardingFeatureOffline => 'Fonctionne sans Internet';

  @override
  String get onboardingFeatureMesh =>
      'Les messages voyagent de téléphone en téléphone';

  @override
  String get onboardingFeatureAlerts => 'Alertes vérifiées par une autorité';

  @override
  String get onboardingProfileTitle => 'Qui êtes-vous ?';

  @override
  String get onboardingProfileBody =>
      'Votre nom est visible dans le salon public. Il n\'est pas vérifié.';

  @override
  String get displayNameLabel => 'Nom affiché';

  @override
  String get displayNameHint => 'Exemple : Rasoa, Voisin A';

  @override
  String get displayNameRequired => 'Entrez un nom affiché.';

  @override
  String get neighborhoodCodeLabel => 'Code du quartier';

  @override
  String get neighborhoodCodeHint => 'Exemple : HAFATRA';

  @override
  String get neighborhoodCodeHelp =>
      'Les personnes qui utilisent le même code se retrouvent. Partagez-le avec vos voisins.';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageMalagasy => 'Malgache';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get backLabel => 'Retour';

  @override
  String get startLabel => 'Commencer';

  @override
  String get skipLabel => 'Passer';

  @override
  String get permissionsTitle => 'Pour que les messages passent';

  @override
  String get permissionsBody =>
      'Hafatra utilise le Bluetooth pour parler aux téléphones proches. Aucune connexion Internet n\'est nécessaire.';

  @override
  String get permissionBluetoothTitle => 'Bluetooth';

  @override
  String get permissionBluetoothBody =>
      'Chercher les téléphones proches et leur transmettre les messages.';

  @override
  String get permissionNotificationTitle => 'Notifications';

  @override
  String get permissionNotificationBody =>
      'Afficher le relais actif et les alertes importantes.';

  @override
  String get permissionBatteryTitle => 'Batterie';

  @override
  String get permissionBatteryBody =>
      'Éviter que le téléphone arrête le relais quand l\'application est en arrière-plan.';

  @override
  String get permissionGranted => 'Autorisé';

  @override
  String get permissionDenied => 'Non autorisé';

  @override
  String get permissionOpenSettings => 'Ouvrir les réglages';

  @override
  String get relayTitle => 'Relais de quartier';

  @override
  String get relayBody =>
      'Votre téléphone peut transmettre les messages des autres. Cela consomme un peu de batterie.';

  @override
  String get relayEnable => 'Activer le relais';

  @override
  String get relayDisable => 'Désactiver le relais';

  @override
  String get chatTitle => 'Salon de quartier';

  @override
  String get navChat => 'Salon';

  @override
  String get navAlerts => 'Alertes';

  @override
  String get navMesh => 'Maillage';

  @override
  String get navSettings => 'Réglages';

  @override
  String get chatSubtitle => 'Messages pour les voisins';

  @override
  String get chatEmptyTitle => 'Aucun message pour le moment';

  @override
  String get chatEmptyBody =>
      'Écrivez votre premier message. S\'il n\'y a personne à portée, il sera conservé et transmis dès qu\'un appareil passera.';

  @override
  String get chatComposerHint => 'Écrire un message…';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String get sendLabel => 'Envoyer';

  @override
  String messageTooLong(int count, int max) {
    return 'Message trop long ($count octets sur $max).';
  }

  @override
  String get messageEmpty => 'Le message est vide.';

  @override
  String get statusQueued => 'En attente';

  @override
  String get statusSent => 'Envoyé au réseau';

  @override
  String get statusRelayed => 'Relayé';

  @override
  String get statusSeen => 'Vu';

  @override
  String get statusDelivered => 'Livré';

  @override
  String get statusFailed => 'Échec';

  @override
  String relayedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relayé par $count appareils',
      one: 'Relayé par 1 appareil',
      zero: 'Relayé par aucun appareil',
    );
    return '$_temp0';
  }

  @override
  String seenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vu par $count personnes',
      one: 'Vu par 1 personne',
      zero: 'Vu par personne',
    );
    return '$_temp0';
  }

  @override
  String get waitingForPeers => 'En attente d\'un téléphone à portée…';

  @override
  String peersNearby(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils à portée',
      one: '1 appareil à portée',
      zero: 'Aucun appareil à portée',
    );
    return '$_temp0';
  }

  @override
  String get meshActive => 'Relais actif';

  @override
  String get meshInactive => 'Relais arrêté';

  @override
  String get batteryLow => 'Batterie faible';

  @override
  String get charging => 'En charge';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsEmptyTitle => 'Aucune alerte';

  @override
  String get alertsEmptyBody =>
      'Les alertes vérifiées par une autorité de confiance apparaîtront ici.';

  @override
  String get alertVerified => 'Alerte vérifiée';

  @override
  String get alertUnverified => 'Alerte non vérifiée';

  @override
  String get alertExpired => 'Alerte expirée';

  @override
  String get alertSeverityInfo => 'Information';

  @override
  String get alertSeverityWarning => 'Vigilance';

  @override
  String get alertSeverityCritical => 'Urgence';

  @override
  String alertAuthority(String authority) {
    return 'Autorité : $authority';
  }

  @override
  String alertExpires(String date) {
    return 'Expire le $date';
  }

  @override
  String get alertView => 'Voir l\'alerte';

  @override
  String get meshTitle => 'État du maillage';

  @override
  String get meshStatus => 'Statut';

  @override
  String get meshTransportBle => 'Bluetooth LE';

  @override
  String get meshTransportSimulated => 'Simulation';

  @override
  String get meshPeers => 'Appareils à portée';

  @override
  String get meshQueue => 'Messages en attente';

  @override
  String get meshSeen => 'Paquets mémorisés';

  @override
  String get meshService => 'Service';

  @override
  String get meshRunning => 'Actif';

  @override
  String get meshStopped => 'Arrêté';

  @override
  String get meshStart => 'Démarrer';

  @override
  String get meshStop => 'Arrêter';

  @override
  String get meshBattery => 'Batterie';

  @override
  String meshThreshold(int percent) {
    return 'Seuil de relais : $percent %';
  }

  @override
  String get meshTest => 'Tester le maillage';

  @override
  String get meshTestMessage => 'Message de test';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsRelay => 'Relais';

  @override
  String get settingsBatteryThreshold => 'Seuil de batterie';

  @override
  String get settingsDiagnostics => 'Diagnostics';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsPermissions => 'Permissions';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get diagnosticsLogs => 'Journaux';

  @override
  String get diagnosticsCopy => 'Copier les journaux';

  @override
  String get diagnosticsCopied => 'Journaux copiés';

  @override
  String get diagnosticsNoLogs => 'Aucun journal pour le moment.';

  @override
  String diagnosticsDevice(String device) {
    return 'Appareil : $device';
  }

  @override
  String diagnosticsService(String status) {
    return 'Service : $status';
  }

  @override
  String diagnosticsTransport(String transport) {
    return 'Transport : $transport';
  }

  @override
  String diagnosticsDatabase(String status) {
    return 'Base locale : $status';
  }

  @override
  String get diagnosticsDemoAlert => 'Injecter une alerte de démonstration';

  @override
  String get diagnosticsDemoAlertAdded => 'Alerte de démonstration ajoutée.';

  @override
  String get aboutTitle => 'À propos de Hafatra';

  @override
  String get aboutBody =>
      'Hafatra est une messagerie hors-ligne pensée pour les quartiers denses, les coupures de réseau et les téléphones d\'entrée de gamme. Les messages voyagent par Bluetooth, de téléphone en téléphone.';

  @override
  String get aboutLicense => 'Logiciel libre — licence MIT.';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get errorStorage => 'Impossible d\'accéder au stockage local.';

  @override
  String get errorCrypto => 'La vérification de sécurité a échoué.';

  @override
  String get errorTransport => 'Le Bluetooth n\'est pas disponible.';

  @override
  String get errorPermission =>
      'Cette permission est nécessaire pour continuer.';

  @override
  String get errorValidation => 'Les données saisies ne sont pas valides.';

  @override
  String get retryLabel => 'Réessayer';

  @override
  String get closeLabel => 'Fermer';

  @override
  String get demoModeTitle => 'Mode démonstration';

  @override
  String get demoModeBody =>
      'Utilise un réseau simulé pour découvrir l\'application sans deuxième téléphone.';

  @override
  String get demoModeEnable => 'Activer la simulation';

  @override
  String get publicChannelWarning =>
      'Ce salon est public : tous les appareils à portée peuvent lire les messages. N\'y mettez pas d\'informations sensibles.';

  @override
  String get retentionNotice =>
      'Les messages sont conservés 30 jours sur cet appareil.';

  @override
  String get backgroundAssistantTitle => 'Garder Hafatra actif';

  @override
  String get backgroundAssistantBody =>
      'Certains téléphones (Tecno, Infinix, Xiaomi, Samsung) arrêtent les applications en arrière-plan. Autorisez Hafatra à rester actif pour continuer à relayer.';

  @override
  String get backgroundAssistantOpenSettings =>
      'Autoriser l\'activité en arrière-plan';

  @override
  String get backgroundAssistantCheck => 'Vérifier le relais';

  @override
  String get backgroundAssistantOk => 'Le relais semble actif.';

  @override
  String get backgroundAssistantProblem =>
      'Le relais est arrêté. Vérifiez les permissions et l\'optimisation de batterie.';

  @override
  String channelCode(String code) {
    return 'Code du quartier : $code';
  }

  @override
  String batteryPercent(int percent) {
    return 'Batterie : $percent %';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get languageChanged => 'Langue mise à jour.';

  @override
  String get settingsSaved => 'Réglages enregistrés.';

  @override
  String get permissionNeededTitle => 'Permission nécessaire';

  @override
  String get permissionNeededBody =>
      'Hafatra a besoin de cette permission pour relayer les messages. Vous pouvez continuer sans, mais le maillage sera limité.';

  @override
  String get notNowLabel => 'Plus tard';

  @override
  String get allowLabel => 'Autoriser';

  @override
  String onboardingStep(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboardingDemoHint =>
      'Vous pourrez changer de mode à tout moment dans les réglages.';

  @override
  String get neighborhoodCodeTooShort =>
      'Le code doit contenir au moins 3 caractères.';

  @override
  String get backgroundNotificationText =>
      'Relais actif — vos messages voyagent de téléphone en téléphone.';

  @override
  String get backgroundNotificationDemoText =>
      'Simulation active — réseau de démonstration.';

  @override
  String get demoWelcomeMessage =>
      'Bienvenue sur Hafatra ! Ce message vient d\'un voisin simulé. Écrivez pour tester le réseau.';

  @override
  String get permissionBluetoothMissing =>
      'Autorisez le Bluetooth pour activer le relais réel.';

  @override
  String get permissionsSkipHint =>
      'Vous pourrez autoriser ces accès plus tard dans les réglages.';

  @override
  String get sendingLabel => 'Envoi…';

  @override
  String get chatYou => 'Vous';

  @override
  String get chatMessageRetentionHint =>
      'Les messages restent 30 jours sur cet appareil.';

  @override
  String get copyChannelCode => 'Copier le code';

  @override
  String get channelCodeCopied => 'Code du quartier copié.';

  @override
  String get meshStarting => 'Démarrage…';

  @override
  String get meshStopping => 'Arrêt…';

  @override
  String get meshError => 'Erreur';

  @override
  String get meshUnavailable => 'Indisponible';

  @override
  String get meshRefresh => 'Actualiser';

  @override
  String get meshPermissionMissing =>
      'Le Bluetooth n\'est pas autorisé. Ouvrez les permissions pour démarrer le relais réel.';

  @override
  String get meshOpenPermissions => 'Ouvrir les permissions';

  @override
  String get meshStartHint =>
      'Le relais démarre automatiquement après l\'introduction. Vous pouvez le relancer ici.';

  @override
  String get meshTestSent => 'Message de test ajouté à la file d\'envoi.';

  @override
  String meshLastError(String error) {
    return 'Dernière erreur : $error';
  }

  @override
  String get meshBatteryCritical => 'Relais suspendu : batterie sous le seuil.';

  @override
  String get meshDemoNotice =>
      'Mode démonstration : les voisins, accusés et reçus sont simulés sur cet appareil.';

  @override
  String get meshThresholdHelp =>
      'Sous ce niveau de batterie, Hafatra arrête de relayer les messages des autres.';

  @override
  String meshStartedAt(String time) {
    return 'Actif depuis $time';
  }

  @override
  String get meshNoPeersHint =>
      'Approchez un autre téléphone avec Hafatra pour créer un lien.';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsMesh => 'Maillage';

  @override
  String get settingsDemoMode => 'Mode démonstration';

  @override
  String get settingsDemoWarning =>
      'La simulation remplace le Bluetooth réel. Désactivez-la pour tester entre plusieurs téléphones.';

  @override
  String get settingsBatteryThresholdHelp =>
      'Le relais s\'arrête sous ce niveau de batterie, sauf si le téléphone charge.';

  @override
  String get settingsPermissionsBody =>
      'Ces accès permettent de relayer les messages et d\'afficher les alertes.';

  @override
  String get settingsOpenSystemSettings => 'Ouvrir les réglages Android';

  @override
  String get settingsChangeName => 'Modifier';

  @override
  String get settingsNameUpdated => 'Nom mis à jour.';

  @override
  String get settingsNameDialogTitle => 'Nom affiché';

  @override
  String get settingsSaveLabel => 'Enregistrer';

  @override
  String get cancelLabel => 'Annuler';

  @override
  String get diagnosticsSystem => 'Système';

  @override
  String get diagnosticsAppVersion => 'Application';

  @override
  String get diagnosticsPlatform => 'Appareil';

  @override
  String get diagnosticsDatabaseOk => 'Ouverte';

  @override
  String get diagnosticsDatabaseError => 'Erreur';

  @override
  String get diagnosticsAlertTools => 'Outils d\'alerte';

  @override
  String diagnosticsAlertRejected(String reason) {
    return 'Alerte refusée : $reason.';
  }

  @override
  String get diagnosticsAlertAdded =>
      'Alerte de démonstration vérifiée et diffusée.';

  @override
  String get diagnosticsLogsHint =>
      'Les journaux ne contiennent ni contenu de message ni identité.';

  @override
  String get diagnosticsPermissions => 'Permissions';

  @override
  String get alertDetailsTitle => 'Détail de l\'alerte';

  @override
  String alertIssued(String date) {
    return 'Émise le $date';
  }

  @override
  String alertArea(String area) {
    return 'Zone : $area';
  }

  @override
  String alertSignature(String fingerprint) {
    return 'Empreinte de signature : $fingerprint';
  }

  @override
  String get alertDemoBadge => 'Démonstration';

  @override
  String get alertDemoHint =>
      'Une alerte de démonstration peut être injectée depuis Diagnostics.';

  @override
  String get aboutPrivacy =>
      'Aucun contenu de message n\'est envoyé à un serveur. Les identités et les clés restent sur le téléphone.';

  @override
  String get aboutOffline => 'Hors-ligne d\'abord, pensé pour Madagascar.';

  @override
  String get aboutPublicChannel =>
      'Le salon de quartier est public : ne partagez pas d\'informations sensibles.';

  @override
  String get unknownLabel => 'Inconnu';

  @override
  String get onLabel => 'Activé';

  @override
  String get offLabel => 'Désactivé';

  @override
  String get serviceLabel => 'Service';

  @override
  String get databaseLabel => 'Base locale';

  @override
  String get refreshLabel => 'Actualiser';

  @override
  String get loadingLabel => 'Chargement…';

  @override
  String get notAvailableLabel => 'Indisponible';

  @override
  String get alertInjectionError =>
      'Impossible d\'injecter l\'alerte de démonstration.';

  @override
  String get openDiagnostics => 'Ouvrir les diagnostics';

  @override
  String get errorMeshNotReady =>
      'Le maillage n\'est pas prêt. Vérifiez les permissions et redémarrez le relais.';

  @override
  String channelLabel(String code) {
    return 'Salon : $code';
  }

  @override
  String relayCounts(int relay, int seen) {
    return 'Relayé par $relay · vu par $seen';
  }

  @override
  String get messageStatusHint =>
      'En attente = conservé sur ce téléphone. Envoyé = transmis à un appareil proche.';

  @override
  String get demoTag => 'Démo';

  @override
  String get bleTag => 'BLE';

  @override
  String get transportLabel => 'Transport';
}
