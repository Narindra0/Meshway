import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('mg'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Hafatra'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'La messagerie qui marche quand le réseau tombe.'**
  String get appTagline;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Hafatra'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez aux personnes autour de vous, même sans Internet et sans crédit.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingFeatureOffline.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionne sans Internet'**
  String get onboardingFeatureOffline;

  /// No description provided for @onboardingFeatureMesh.
  ///
  /// In fr, this message translates to:
  /// **'Les messages voyagent de téléphone en téléphone'**
  String get onboardingFeatureMesh;

  /// No description provided for @onboardingFeatureAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes vérifiées par une autorité'**
  String get onboardingFeatureAlerts;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qui êtes-vous ?'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom est visible dans le salon public. Il n\'est pas vérifié.'**
  String get onboardingProfileBody;

  /// No description provided for @displayNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Exemple : Rasoa, Voisin A'**
  String get displayNameHint;

  /// No description provided for @displayNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nom affiché.'**
  String get displayNameRequired;

  /// No description provided for @neighborhoodCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code du quartier'**
  String get neighborhoodCodeLabel;

  /// No description provided for @neighborhoodCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Exemple : HAFATRA'**
  String get neighborhoodCodeHint;

  /// No description provided for @neighborhoodCodeHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les personnes qui utilisent le même code se retrouvent. Partagez-le avec vos voisins.'**
  String get neighborhoodCodeHelp;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageMalagasy.
  ///
  /// In fr, this message translates to:
  /// **'Malgache'**
  String get languageMalagasy;

  /// No description provided for @themeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @continueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueLabel;

  /// No description provided for @backLabel.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get backLabel;

  /// No description provided for @startLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get startLabel;

  /// No description provided for @skipLabel.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skipLabel;

  /// No description provided for @permissionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour que les messages passent'**
  String get permissionsTitle;

  /// No description provided for @permissionsBody.
  ///
  /// In fr, this message translates to:
  /// **'Hafatra utilise le Bluetooth pour parler aux téléphones proches. Aucune connexion Internet n\'est nécessaire.'**
  String get permissionsBody;

  /// No description provided for @permissionBluetoothTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth'**
  String get permissionBluetoothTitle;

  /// No description provided for @permissionBluetoothBody.
  ///
  /// In fr, this message translates to:
  /// **'Chercher les téléphones proches et leur transmettre les messages.'**
  String get permissionBluetoothBody;

  /// No description provided for @permissionNotificationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get permissionNotificationTitle;

  /// No description provided for @permissionNotificationBody.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le relais actif et les alertes importantes.'**
  String get permissionNotificationBody;

  /// No description provided for @permissionBatteryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Batterie'**
  String get permissionBatteryTitle;

  /// No description provided for @permissionBatteryBody.
  ///
  /// In fr, this message translates to:
  /// **'Éviter que le téléphone arrête le relais quand l\'application est en arrière-plan.'**
  String get permissionBatteryBody;

  /// No description provided for @permissionGranted.
  ///
  /// In fr, this message translates to:
  /// **'Autorisé'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Non autorisé'**
  String get permissionDenied;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get permissionOpenSettings;

  /// No description provided for @relayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relais de quartier'**
  String get relayTitle;

  /// No description provided for @relayBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre téléphone peut transmettre les messages des autres. Cela consomme un peu de batterie.'**
  String get relayBody;

  /// No description provided for @relayEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer le relais'**
  String get relayEnable;

  /// No description provided for @relayDisable.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver le relais'**
  String get relayDisable;

  /// No description provided for @chatTitle.
  ///
  /// In fr, this message translates to:
  /// **'Salon de quartier'**
  String get chatTitle;

  /// No description provided for @navChat.
  ///
  /// In fr, this message translates to:
  /// **'Salon'**
  String get navChat;

  /// No description provided for @navAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get navAlerts;

  /// No description provided for @navMesh.
  ///
  /// In fr, this message translates to:
  /// **'Maillage'**
  String get navMesh;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @chatSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Messages pour les voisins'**
  String get chatSubtitle;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message pour le moment'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez votre premier message. S\'il n\'y a personne à portée, il sera conservé et transmis dès qu\'un appareil passera.'**
  String get chatEmptyBody;

  /// No description provided for @chatComposerHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un message…'**
  String get chatComposerHint;

  /// No description provided for @dateToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get dateYesterday;

  /// No description provided for @sendLabel.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get sendLabel;

  /// No description provided for @messageTooLong.
  ///
  /// In fr, this message translates to:
  /// **'Message trop long ({count} octets sur {max}).'**
  String messageTooLong(int count, int max);

  /// No description provided for @messageEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le message est vide.'**
  String get messageEmpty;

  /// No description provided for @statusQueued.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusQueued;

  /// No description provided for @statusSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé au réseau'**
  String get statusSent;

  /// No description provided for @statusRelayed.
  ///
  /// In fr, this message translates to:
  /// **'Relayé'**
  String get statusRelayed;

  /// No description provided for @statusSeen.
  ///
  /// In fr, this message translates to:
  /// **'Vu'**
  String get statusSeen;

  /// No description provided for @statusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livré'**
  String get statusDelivered;

  /// No description provided for @statusFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get statusFailed;

  /// No description provided for @relayedBy.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Relayé par aucun appareil} =1{Relayé par 1 appareil} other{Relayé par {count} appareils}}'**
  String relayedBy(int count);

  /// No description provided for @seenBy.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Vu par personne} =1{Vu par 1 personne} other{Vu par {count} personnes}}'**
  String seenBy(int count);

  /// No description provided for @waitingForPeers.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'un téléphone à portée…'**
  String get waitingForPeers;

  /// No description provided for @peersNearby.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun appareil à portée} =1{1 appareil à portée} other{{count} appareils à portée}}'**
  String peersNearby(int count);

  /// No description provided for @meshActive.
  ///
  /// In fr, this message translates to:
  /// **'Relais actif'**
  String get meshActive;

  /// No description provided for @meshInactive.
  ///
  /// In fr, this message translates to:
  /// **'Relais arrêté'**
  String get meshInactive;

  /// No description provided for @batteryLow.
  ///
  /// In fr, this message translates to:
  /// **'Batterie faible'**
  String get batteryLow;

  /// No description provided for @charging.
  ///
  /// In fr, this message translates to:
  /// **'En charge'**
  String get charging;

  /// No description provided for @alertsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertsTitle;

  /// No description provided for @alertsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte'**
  String get alertsEmptyTitle;

  /// No description provided for @alertsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les alertes vérifiées par une autorité de confiance apparaîtront ici.'**
  String get alertsEmptyBody;

  /// No description provided for @alertVerified.
  ///
  /// In fr, this message translates to:
  /// **'Alerte vérifiée'**
  String get alertVerified;

  /// No description provided for @alertUnverified.
  ///
  /// In fr, this message translates to:
  /// **'Alerte non vérifiée'**
  String get alertUnverified;

  /// No description provided for @alertExpired.
  ///
  /// In fr, this message translates to:
  /// **'Alerte expirée'**
  String get alertExpired;

  /// No description provided for @alertSeverityInfo.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get alertSeverityInfo;

  /// No description provided for @alertSeverityWarning.
  ///
  /// In fr, this message translates to:
  /// **'Vigilance'**
  String get alertSeverityWarning;

  /// No description provided for @alertSeverityCritical.
  ///
  /// In fr, this message translates to:
  /// **'Urgence'**
  String get alertSeverityCritical;

  /// No description provided for @alertAuthority.
  ///
  /// In fr, this message translates to:
  /// **'Autorité : {authority}'**
  String alertAuthority(String authority);

  /// No description provided for @alertExpires.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date}'**
  String alertExpires(String date);

  /// No description provided for @alertView.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'alerte'**
  String get alertView;

  /// No description provided for @meshTitle.
  ///
  /// In fr, this message translates to:
  /// **'État du maillage'**
  String get meshTitle;

  /// No description provided for @meshStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get meshStatus;

  /// No description provided for @meshTransportBle.
  ///
  /// In fr, this message translates to:
  /// **'Bluetooth LE'**
  String get meshTransportBle;

  /// No description provided for @meshTransportSimulated.
  ///
  /// In fr, this message translates to:
  /// **'Simulation'**
  String get meshTransportSimulated;

  /// No description provided for @meshPeers.
  ///
  /// In fr, this message translates to:
  /// **'Appareils à portée'**
  String get meshPeers;

  /// No description provided for @meshQueue.
  ///
  /// In fr, this message translates to:
  /// **'Messages en attente'**
  String get meshQueue;

  /// No description provided for @meshSeen.
  ///
  /// In fr, this message translates to:
  /// **'Paquets mémorisés'**
  String get meshSeen;

  /// No description provided for @meshService.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get meshService;

  /// No description provided for @meshRunning.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get meshRunning;

  /// No description provided for @meshStopped.
  ///
  /// In fr, this message translates to:
  /// **'Arrêté'**
  String get meshStopped;

  /// No description provided for @meshStart.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get meshStart;

  /// No description provided for @meshStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get meshStop;

  /// No description provided for @meshBattery.
  ///
  /// In fr, this message translates to:
  /// **'Batterie'**
  String get meshBattery;

  /// No description provided for @meshThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de relais : {percent} %'**
  String meshThreshold(int percent);

  /// No description provided for @meshTest.
  ///
  /// In fr, this message translates to:
  /// **'Tester le maillage'**
  String get meshTest;

  /// No description provided for @meshTestMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message de test'**
  String get meshTestMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @settingsRelay.
  ///
  /// In fr, this message translates to:
  /// **'Relais'**
  String get settingsRelay;

  /// No description provided for @settingsBatteryThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de batterie'**
  String get settingsBatteryThreshold;

  /// No description provided for @settingsDiagnostics.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostics'**
  String get settingsDiagnostics;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Permissions'**
  String get settingsPermissions;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @diagnosticsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsLogs.
  ///
  /// In fr, this message translates to:
  /// **'Journaux'**
  String get diagnosticsLogs;

  /// No description provided for @diagnosticsCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier les journaux'**
  String get diagnosticsCopy;

  /// No description provided for @diagnosticsCopied.
  ///
  /// In fr, this message translates to:
  /// **'Journaux copiés'**
  String get diagnosticsCopied;

  /// No description provided for @diagnosticsNoLogs.
  ///
  /// In fr, this message translates to:
  /// **'Aucun journal pour le moment.'**
  String get diagnosticsNoLogs;

  /// No description provided for @diagnosticsDevice.
  ///
  /// In fr, this message translates to:
  /// **'Appareil : {device}'**
  String diagnosticsDevice(String device);

  /// No description provided for @diagnosticsService.
  ///
  /// In fr, this message translates to:
  /// **'Service : {status}'**
  String diagnosticsService(String status);

  /// No description provided for @diagnosticsTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport : {transport}'**
  String diagnosticsTransport(String transport);

  /// No description provided for @diagnosticsDatabase.
  ///
  /// In fr, this message translates to:
  /// **'Base locale : {status}'**
  String diagnosticsDatabase(String status);

  /// No description provided for @diagnosticsDemoAlert.
  ///
  /// In fr, this message translates to:
  /// **'Injecter une alerte de démonstration'**
  String get diagnosticsDemoAlert;

  /// No description provided for @diagnosticsDemoAlertAdded.
  ///
  /// In fr, this message translates to:
  /// **'Alerte de démonstration ajoutée.'**
  String get diagnosticsDemoAlertAdded;

  /// No description provided for @aboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos de Hafatra'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In fr, this message translates to:
  /// **'Hafatra est une messagerie hors-ligne pensée pour les quartiers denses, les coupures de réseau et les téléphones d\'entrée de gamme. Les messages voyagent par Bluetooth, de téléphone en téléphone.'**
  String get aboutBody;

  /// No description provided for @aboutLicense.
  ///
  /// In fr, this message translates to:
  /// **'Logiciel libre — licence MIT.'**
  String get aboutLicense;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorGeneric;

  /// No description provided for @errorStorage.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'accéder au stockage local.'**
  String get errorStorage;

  /// No description provided for @errorCrypto.
  ///
  /// In fr, this message translates to:
  /// **'La vérification de sécurité a échoué.'**
  String get errorCrypto;

  /// No description provided for @errorTransport.
  ///
  /// In fr, this message translates to:
  /// **'Le Bluetooth n\'est pas disponible.'**
  String get errorTransport;

  /// No description provided for @errorPermission.
  ///
  /// In fr, this message translates to:
  /// **'Cette permission est nécessaire pour continuer.'**
  String get errorPermission;

  /// No description provided for @errorValidation.
  ///
  /// In fr, this message translates to:
  /// **'Les données saisies ne sont pas valides.'**
  String get errorValidation;

  /// No description provided for @retryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retryLabel;

  /// No description provided for @closeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get closeLabel;

  /// No description provided for @demoModeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode démonstration'**
  String get demoModeTitle;

  /// No description provided for @demoModeBody.
  ///
  /// In fr, this message translates to:
  /// **'Utilise un réseau simulé pour découvrir l\'application sans deuxième téléphone.'**
  String get demoModeBody;

  /// No description provided for @demoModeEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer la simulation'**
  String get demoModeEnable;

  /// No description provided for @publicChannelWarning.
  ///
  /// In fr, this message translates to:
  /// **'Ce salon est public : tous les appareils à portée peuvent lire les messages. N\'y mettez pas d\'informations sensibles.'**
  String get publicChannelWarning;

  /// No description provided for @retentionNotice.
  ///
  /// In fr, this message translates to:
  /// **'Les messages sont conservés 30 jours sur cet appareil.'**
  String get retentionNotice;

  /// No description provided for @backgroundAssistantTitle.
  ///
  /// In fr, this message translates to:
  /// **'Garder Hafatra actif'**
  String get backgroundAssistantTitle;

  /// No description provided for @backgroundAssistantBody.
  ///
  /// In fr, this message translates to:
  /// **'Certains téléphones (Tecno, Infinix, Xiaomi, Samsung) arrêtent les applications en arrière-plan. Autorisez Hafatra à rester actif pour continuer à relayer.'**
  String get backgroundAssistantBody;

  /// No description provided for @backgroundAssistantOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser l\'activité en arrière-plan'**
  String get backgroundAssistantOpenSettings;

  /// No description provided for @backgroundAssistantCheck.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le relais'**
  String get backgroundAssistantCheck;

  /// No description provided for @backgroundAssistantOk.
  ///
  /// In fr, this message translates to:
  /// **'Le relais semble actif.'**
  String get backgroundAssistantOk;

  /// No description provided for @backgroundAssistantProblem.
  ///
  /// In fr, this message translates to:
  /// **'Le relais est arrêté. Vérifiez les permissions et l\'optimisation de batterie.'**
  String get backgroundAssistantProblem;

  /// No description provided for @channelCode.
  ///
  /// In fr, this message translates to:
  /// **'Code du quartier : {code}'**
  String channelCode(String code);

  /// No description provided for @batteryPercent.
  ///
  /// In fr, this message translates to:
  /// **'Batterie : {percent} %'**
  String batteryPercent(int percent);

  /// No description provided for @versionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @languageChanged.
  ///
  /// In fr, this message translates to:
  /// **'Langue mise à jour.'**
  String get languageChanged;

  /// No description provided for @settingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Réglages enregistrés.'**
  String get settingsSaved;

  /// No description provided for @permissionNeededTitle.
  ///
  /// In fr, this message translates to:
  /// **'Permission nécessaire'**
  String get permissionNeededTitle;

  /// No description provided for @permissionNeededBody.
  ///
  /// In fr, this message translates to:
  /// **'Hafatra a besoin de cette permission pour relayer les messages. Vous pouvez continuer sans, mais le maillage sera limité.'**
  String get permissionNeededBody;

  /// No description provided for @notNowLabel.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get notNowLabel;

  /// No description provided for @allowLabel.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get allowLabel;

  /// No description provided for @onboardingStep.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} sur {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingDemoHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez changer de mode à tout moment dans les réglages.'**
  String get onboardingDemoHint;

  /// No description provided for @neighborhoodCodeTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le code doit contenir au moins 3 caractères.'**
  String get neighborhoodCodeTooShort;

  /// No description provided for @backgroundNotificationText.
  ///
  /// In fr, this message translates to:
  /// **'Relais actif — vos messages voyagent de téléphone en téléphone.'**
  String get backgroundNotificationText;

  /// No description provided for @backgroundNotificationDemoText.
  ///
  /// In fr, this message translates to:
  /// **'Simulation active — réseau de démonstration.'**
  String get backgroundNotificationDemoText;

  /// No description provided for @demoWelcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Hafatra ! Ce message vient d\'un voisin simulé. Écrivez pour tester le réseau.'**
  String get demoWelcomeMessage;

  /// No description provided for @permissionBluetoothMissing.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez le Bluetooth pour activer le relais réel.'**
  String get permissionBluetoothMissing;

  /// No description provided for @permissionsSkipHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez autoriser ces accès plus tard dans les réglages.'**
  String get permissionsSkipHint;

  /// No description provided for @sendingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Envoi…'**
  String get sendingLabel;

  /// No description provided for @chatYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get chatYou;

  /// No description provided for @chatMessageRetentionHint.
  ///
  /// In fr, this message translates to:
  /// **'Les messages restent 30 jours sur cet appareil.'**
  String get chatMessageRetentionHint;

  /// No description provided for @copyChannelCode.
  ///
  /// In fr, this message translates to:
  /// **'Copier le code'**
  String get copyChannelCode;

  /// No description provided for @channelCodeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code du quartier copié.'**
  String get channelCodeCopied;

  /// No description provided for @meshStarting.
  ///
  /// In fr, this message translates to:
  /// **'Démarrage…'**
  String get meshStarting;

  /// No description provided for @meshStopping.
  ///
  /// In fr, this message translates to:
  /// **'Arrêt…'**
  String get meshStopping;

  /// No description provided for @meshError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get meshError;

  /// No description provided for @meshUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get meshUnavailable;

  /// No description provided for @meshRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get meshRefresh;

  /// No description provided for @meshPermissionMissing.
  ///
  /// In fr, this message translates to:
  /// **'Le Bluetooth n\'est pas autorisé. Ouvrez les permissions pour démarrer le relais réel.'**
  String get meshPermissionMissing;

  /// No description provided for @meshOpenPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les permissions'**
  String get meshOpenPermissions;

  /// No description provided for @meshStartHint.
  ///
  /// In fr, this message translates to:
  /// **'Le relais démarre automatiquement après l\'introduction. Vous pouvez le relancer ici.'**
  String get meshStartHint;

  /// No description provided for @meshTestSent.
  ///
  /// In fr, this message translates to:
  /// **'Message de test ajouté à la file d\'envoi.'**
  String get meshTestSent;

  /// No description provided for @meshLastError.
  ///
  /// In fr, this message translates to:
  /// **'Dernière erreur : {error}'**
  String meshLastError(String error);

  /// No description provided for @meshBatteryCritical.
  ///
  /// In fr, this message translates to:
  /// **'Relais suspendu : batterie sous le seuil.'**
  String get meshBatteryCritical;

  /// No description provided for @meshDemoNotice.
  ///
  /// In fr, this message translates to:
  /// **'Mode démonstration : les voisins, accusés et reçus sont simulés sur cet appareil.'**
  String get meshDemoNotice;

  /// No description provided for @meshThresholdHelp.
  ///
  /// In fr, this message translates to:
  /// **'Sous ce niveau de batterie, Hafatra arrête de relayer les messages des autres.'**
  String get meshThresholdHelp;

  /// No description provided for @meshStartedAt.
  ///
  /// In fr, this message translates to:
  /// **'Actif depuis {time}'**
  String meshStartedAt(String time);

  /// No description provided for @meshNoPeersHint.
  ///
  /// In fr, this message translates to:
  /// **'Approchez un autre téléphone avec Hafatra pour créer un lien.'**
  String get meshNoPeersHint;

  /// No description provided for @settingsProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsMesh.
  ///
  /// In fr, this message translates to:
  /// **'Maillage'**
  String get settingsMesh;

  /// No description provided for @settingsDemoMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode démonstration'**
  String get settingsDemoMode;

  /// No description provided for @settingsDemoWarning.
  ///
  /// In fr, this message translates to:
  /// **'La simulation remplace le Bluetooth réel. Désactivez-la pour tester entre plusieurs téléphones.'**
  String get settingsDemoWarning;

  /// No description provided for @settingsBatteryThresholdHelp.
  ///
  /// In fr, this message translates to:
  /// **'Le relais s\'arrête sous ce niveau de batterie, sauf si le téléphone charge.'**
  String get settingsBatteryThresholdHelp;

  /// No description provided for @settingsPermissionsBody.
  ///
  /// In fr, this message translates to:
  /// **'Ces accès permettent de relayer les messages et d\'afficher les alertes.'**
  String get settingsPermissionsBody;

  /// No description provided for @settingsOpenSystemSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages Android'**
  String get settingsOpenSystemSettings;

  /// No description provided for @settingsChangeName.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get settingsChangeName;

  /// No description provided for @settingsNameUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Nom mis à jour.'**
  String get settingsNameUpdated;

  /// No description provided for @settingsNameDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché'**
  String get settingsNameDialogTitle;

  /// No description provided for @settingsSaveLabel.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get settingsSaveLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelLabel;

  /// No description provided for @diagnosticsSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get diagnosticsSystem;

  /// No description provided for @diagnosticsAppVersion.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get diagnosticsAppVersion;

  /// No description provided for @diagnosticsPlatform.
  ///
  /// In fr, this message translates to:
  /// **'Appareil'**
  String get diagnosticsPlatform;

  /// No description provided for @diagnosticsDatabaseOk.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get diagnosticsDatabaseOk;

  /// No description provided for @diagnosticsDatabaseError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get diagnosticsDatabaseError;

  /// No description provided for @diagnosticsAlertTools.
  ///
  /// In fr, this message translates to:
  /// **'Outils d\'alerte'**
  String get diagnosticsAlertTools;

  /// No description provided for @diagnosticsAlertRejected.
  ///
  /// In fr, this message translates to:
  /// **'Alerte refusée : {reason}.'**
  String diagnosticsAlertRejected(String reason);

  /// No description provided for @diagnosticsAlertAdded.
  ///
  /// In fr, this message translates to:
  /// **'Alerte de démonstration vérifiée et diffusée.'**
  String get diagnosticsAlertAdded;

  /// No description provided for @diagnosticsLogsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les journaux ne contiennent ni contenu de message ni identité.'**
  String get diagnosticsLogsHint;

  /// No description provided for @diagnosticsPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Permissions'**
  String get diagnosticsPermissions;

  /// No description provided for @alertDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail de l\'alerte'**
  String get alertDetailsTitle;

  /// No description provided for @alertIssued.
  ///
  /// In fr, this message translates to:
  /// **'Émise le {date}'**
  String alertIssued(String date);

  /// No description provided for @alertArea.
  ///
  /// In fr, this message translates to:
  /// **'Zone : {area}'**
  String alertArea(String area);

  /// No description provided for @alertSignature.
  ///
  /// In fr, this message translates to:
  /// **'Empreinte de signature : {fingerprint}'**
  String alertSignature(String fingerprint);

  /// No description provided for @alertDemoBadge.
  ///
  /// In fr, this message translates to:
  /// **'Démonstration'**
  String get alertDemoBadge;

  /// No description provided for @alertDemoHint.
  ///
  /// In fr, this message translates to:
  /// **'Une alerte de démonstration peut être injectée depuis Diagnostics.'**
  String get alertDemoHint;

  /// No description provided for @aboutPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contenu de message n\'est envoyé à un serveur. Les identités et les clés restent sur le téléphone.'**
  String get aboutPrivacy;

  /// No description provided for @aboutOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors-ligne d\'abord, pensé pour Madagascar.'**
  String get aboutOffline;

  /// No description provided for @aboutPublicChannel.
  ///
  /// In fr, this message translates to:
  /// **'Le salon de quartier est public : ne partagez pas d\'informations sensibles.'**
  String get aboutPublicChannel;

  /// No description provided for @unknownLabel.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknownLabel;

  /// No description provided for @onLabel.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get onLabel;

  /// No description provided for @offLabel.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get offLabel;

  /// No description provided for @serviceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// No description provided for @databaseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Base locale'**
  String get databaseLabel;

  /// No description provided for @refreshLabel.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refreshLabel;

  /// No description provided for @loadingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loadingLabel;

  /// No description provided for @notAvailableLabel.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get notAvailableLabel;

  /// No description provided for @alertInjectionError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'injecter l\'alerte de démonstration.'**
  String get alertInjectionError;

  /// No description provided for @openDiagnostics.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les diagnostics'**
  String get openDiagnostics;

  /// No description provided for @errorMeshNotReady.
  ///
  /// In fr, this message translates to:
  /// **'Le maillage n\'est pas prêt. Vérifiez les permissions et redémarrez le relais.'**
  String get errorMeshNotReady;

  /// No description provided for @channelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Salon : {code}'**
  String channelLabel(String code);

  /// No description provided for @relayCounts.
  ///
  /// In fr, this message translates to:
  /// **'Relayé par {relay} · vu par {seen}'**
  String relayCounts(int relay, int seen);

  /// No description provided for @messageStatusHint.
  ///
  /// In fr, this message translates to:
  /// **'En attente = conservé sur ce téléphone. Envoyé = transmis à un appareil proche.'**
  String get messageStatusHint;

  /// No description provided for @demoTag.
  ///
  /// In fr, this message translates to:
  /// **'Démo'**
  String get demoTag;

  /// No description provided for @bleTag.
  ///
  /// In fr, this message translates to:
  /// **'BLE'**
  String get bleTag;

  /// No description provided for @transportLabel.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get transportLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
