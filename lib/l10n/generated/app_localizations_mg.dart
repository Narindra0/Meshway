// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appName => 'Hafatra';

  @override
  String get appTagline =>
      'Ny hafatra mandeha na dia tapaka aza ny tambajotra.';

  @override
  String get onboardingWelcomeTitle => 'Tongasoa eto Hafatra';

  @override
  String get onboardingWelcomeBody =>
      'Mifandraisa amin\'ny olona manodidina anao na dia tsy misy Internet sy crédit aza.';

  @override
  String get onboardingFeatureOffline => 'Mandeha tsy misy Internet';

  @override
  String get onboardingFeatureMesh => 'Mamakivaky telefaona ny hafatra';

  @override
  String get onboardingFeatureAlerts => 'Fampitandremana voamarina';

  @override
  String get onboardingProfileTitle => 'Iza ianao?';

  @override
  String get onboardingProfileBody =>
      'Hita ao amin\'ny efitrano ampahibemaso ny anaranao. Tsy voamarina izy.';

  @override
  String get displayNameLabel => 'Anarana aseho';

  @override
  String get displayNameHint => 'Ohatra: Rasoa, Voisin A';

  @override
  String get displayNameRequired => 'Ampidiro ny anarana aseho.';

  @override
  String get neighborhoodCodeLabel => 'Kaody ny faritra';

  @override
  String get neighborhoodCodeHint => 'Ohatra: HAFATRA';

  @override
  String get neighborhoodCodeHelp =>
      'Olona mitovy kaody ihany no hifankahita. Zarao amin\'ny mpifanila trano izy.';

  @override
  String get languageLabel => 'Fiteny';

  @override
  String get languageFrench => 'Frantsay';

  @override
  String get languageMalagasy => 'Malagasy';

  @override
  String get themeLabel => 'Endrika';

  @override
  String get themeSystem => 'Manaraka ny rafitra';

  @override
  String get themeLight => 'Mazava';

  @override
  String get themeDark => 'Maizina';

  @override
  String get continueLabel => 'Hanohy';

  @override
  String get backLabel => 'Hiverina';

  @override
  String get startLabel => 'Hanomboka';

  @override
  String get skipLabel => 'Hitsambikina';

  @override
  String get permissionsTitle => 'Mba hahafahan\'ny hafatra mandeha';

  @override
  String get permissionsBody =>
      'Mampiasa Bluetooth i Hafatra mba hifandraisana amin\'ny telefaona akaiky. Tsy mila Internet.';

  @override
  String get permissionBluetoothTitle => 'Bluetooth';

  @override
  String get permissionBluetoothBody =>
      'Hikaroka sy handefa hafatra amin\'ny telefaona akaiky.';

  @override
  String get permissionNotificationTitle => 'Fampandrenesana';

  @override
  String get permissionNotificationBody =>
      'Hampiseho ny relay mandeha sy ny fampitandremana lehibe.';

  @override
  String get permissionBatteryTitle => 'Batterie';

  @override
  String get permissionBatteryBody =>
      'Mba tsy hikatona ny relay rehefa mijanona ny application.';

  @override
  String get permissionGranted => 'Efa navela';

  @override
  String get permissionDenied => 'Tsy navela';

  @override
  String get permissionOpenSettings => 'Sokafy ny fikirakirana';

  @override
  String get relayTitle => 'Relay ny faritra';

  @override
  String get relayBody =>
      'Afaka mampita hafatra avy amin\'ny hafa ny telefaoninao. Mety hihinana batterie kely izany.';

  @override
  String get relayEnable => 'Alefaso ny relay';

  @override
  String get relayDisable => 'Ajanony ny relay';

  @override
  String get chatTitle => 'Efitrano ifandraisana';

  @override
  String get navChat => 'Efitrano';

  @override
  String get navAlerts => 'Fampitandremana';

  @override
  String get navMesh => 'Relay';

  @override
  String get navSettings => 'Fikirana';

  @override
  String get chatSubtitle => 'Hafatra ho an\'ny mpifanila trano';

  @override
  String get chatEmptyTitle => 'Tsy misy hafatra mbola';

  @override
  String get chatEmptyBody =>
      'Soraty ny hafatrao. Raha tsy misy telefaona akaiky, tehirizo izy ary halefa rehefa misy relay.';

  @override
  String get chatComposerHint => 'Soraty eto…';

  @override
  String get dateToday => 'Anio';

  @override
  String get dateYesterday => 'Omaly';

  @override
  String get sendLabel => 'Alefa';

  @override
  String messageTooLong(int count, int max) {
    return 'Lava loatra ny hafatra ($count octets / $max).';
  }

  @override
  String get messageEmpty => 'Tsy misy zavatra ao amin\'ny hafatra.';

  @override
  String get statusQueued => 'Miandry';

  @override
  String get statusSent => 'Nalefa tamin\'ny tambajotra';

  @override
  String get statusRelayed => 'Nampitaina';

  @override
  String get statusSeen => 'Hita';

  @override
  String get statusDelivered => 'Voadray';

  @override
  String get statusFailed => 'Tsy nahomby';

  @override
  String relayedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nampitaina tamin\'ny fitaovana $count',
      one: 'Nampitaina tamin\'ny fitaovana 1',
      zero: 'Tsy mbola nampitaina',
    );
    return '$_temp0';
  }

  @override
  String seenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hita tamin\'ny olona $count',
      one: 'Hita tamin\'ny olona 1',
      zero: 'Tsy mbola hita',
    );
    return '$_temp0';
  }

  @override
  String get waitingForPeers => 'Miandry telefaona akaiky…';

  @override
  String peersNearby(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fitaovana akaiky',
      one: '1 fitaovana akaiky',
      zero: 'Tsy misy fitaovana akaiky',
    );
    return '$_temp0';
  }

  @override
  String get meshActive => 'Mandeha ny relay';

  @override
  String get meshInactive => 'Tapaka ny relay';

  @override
  String get batteryLow => 'Latsaka ny batterie';

  @override
  String get charging => 'Mampiditra herinaratra';

  @override
  String get alertsTitle => 'Fampitandremana';

  @override
  String get alertsEmptyTitle => 'Tsy misy fampitandremana';

  @override
  String get alertsEmptyBody =>
      'Ny fampitandremana voamarina avy amin\'ny manam-pahefana no hiseho eto.';

  @override
  String get alertVerified => 'Fampitandremana voamarina';

  @override
  String get alertUnverified => 'Fampitandremana tsy voamarina';

  @override
  String get alertExpired => 'Lany andro ny fampitandremana';

  @override
  String get alertSeverityInfo => 'Fampahafantarana';

  @override
  String get alertSeverityWarning => 'Mitandrina';

  @override
  String get alertSeverityCritical => 'Maika';

  @override
  String alertAuthority(String authority) {
    return 'Manam-pahefana: $authority';
  }

  @override
  String alertExpires(String date) {
    return 'Lany andro $date';
  }

  @override
  String get alertView => 'Hijery ny fampitandremana';

  @override
  String get meshTitle => 'Toe-javatra relay';

  @override
  String get meshStatus => 'Sata';

  @override
  String get meshTransportBle => 'Bluetooth LE';

  @override
  String get meshTransportSimulated => 'Simulation';

  @override
  String get meshPeers => 'Fitaovana akaiky';

  @override
  String get meshQueue => 'Hafatra miandry';

  @override
  String get meshSeen => 'Paquet voatahiry';

  @override
  String get meshService => 'Serivisy';

  @override
  String get meshRunning => 'Mandeha';

  @override
  String get meshStopped => 'Mijanona';

  @override
  String get meshStart => 'Alefaso';

  @override
  String get meshStop => 'Ajanony';

  @override
  String get meshBattery => 'Batterie';

  @override
  String meshThreshold(int percent) {
    return 'Seuil relay: $percent %';
  }

  @override
  String get meshTest => 'Andramo ny fifandraisana';

  @override
  String get meshTestMessage => 'Hafatra fanandramana';

  @override
  String get settingsTitle => 'Fikirana';

  @override
  String get settingsLanguage => 'Fiteny';

  @override
  String get settingsTheme => 'Endrika';

  @override
  String get settingsRelay => 'Relay';

  @override
  String get settingsBatteryThreshold => 'Seuil batterie';

  @override
  String get settingsDiagnostics => 'Diagnostics';

  @override
  String get settingsAbout => 'Momba';

  @override
  String get settingsPermissions => 'Fahazoan-dalana';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get diagnosticsLogs => 'Tantara (logs)';

  @override
  String get diagnosticsCopy => 'Adikao ny logs';

  @override
  String get diagnosticsCopied => 'Voatahiry ny logs';

  @override
  String get diagnosticsNoLogs => 'Tsy misy log amin\'izao.';

  @override
  String diagnosticsDevice(String device) {
    return 'Fitaovana: $device';
  }

  @override
  String diagnosticsService(String status) {
    return 'Serivisy: $status';
  }

  @override
  String diagnosticsTransport(String transport) {
    return 'Transport: $transport';
  }

  @override
  String diagnosticsDatabase(String status) {
    return 'Tahiry: $status';
  }

  @override
  String get diagnosticsDemoAlert => 'Ampidiro ny fampitandremana fanandramana';

  @override
  String get diagnosticsDemoAlertAdded =>
      'Nampidirina ny fampitandremana fanandramana.';

  @override
  String get aboutTitle => 'Momba an\'i Hafatra';

  @override
  String get aboutBody =>
      'Hafatra dia messagerie hors-ligne ho an\'ny faritra misy cyclone, coupure ary telefaona tsotra. Mamakivaky telefaona ny hafatra amin\'ny alalan\'ny Bluetooth.';

  @override
  String get aboutLicense => 'Logiciel libre — licence MIT.';

  @override
  String get errorGeneric => 'Nisy olana. Andramo indray.';

  @override
  String get errorStorage => 'Tsy afaka namaky ny tahiry.';

  @override
  String get errorCrypto => 'Tsy nahomby ny fanamarinana.';

  @override
  String get errorTransport => 'Tsy misy Bluetooth.';

  @override
  String get errorPermission => 'Ilaina io fahazoan-dalana io mba hanohizana.';

  @override
  String get errorValidation => 'Tsy mety ny angona nampidirina.';

  @override
  String get retryLabel => 'Andramo indray';

  @override
  String get closeLabel => 'Hidio';

  @override
  String get demoModeTitle => 'Mode démonstration';

  @override
  String get demoModeBody =>
      'Mampiasa tambajotra simulation izy ity mba hijery ny endriny tsy misy telefaona roa.';

  @override
  String get demoModeEnable => 'Alefaso ny simulation';

  @override
  String get publicChannelWarning =>
      'Ampahibemaso ity efitrano ity: afaka mamaky ny hafatra ny fitaovana rehetra akaiky. Aza manoratra vaovao tsy miankina.';

  @override
  String get retentionNotice =>
      'Voatahiry 30 andro ao amin\'ity telefaona ity ny hafatra.';

  @override
  String get backgroundAssistantTitle => 'Ampio hijanona i Hafatra';

  @override
  String get backgroundAssistantBody =>
      'Ny telefaona sasany (Tecno, Infinix, Xiaomi, Samsung) dia mamono ny application rehefa mijanona. Avelao hijanona i Hafatra mba hanohizany ny relay.';

  @override
  String get backgroundAssistantOpenSettings => 'Avelao hiasa ao ambadika';

  @override
  String get backgroundAssistantCheck => 'Hamarinin\'ny relay';

  @override
  String get backgroundAssistantOk => 'Toa mandeha ny relay.';

  @override
  String get backgroundAssistantProblem =>
      'Tapaka ny relay. Hamarino ny fahazoan-dalana sy ny batterie.';

  @override
  String channelCode(String code) {
    return 'Kaody ny faritra: $code';
  }

  @override
  String batteryPercent(int percent) {
    return 'Batterie: $percent %';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get languageChanged => 'Voaova ny fiteny.';

  @override
  String get settingsSaved => 'Voatahiry ny fikirana.';

  @override
  String get permissionNeededTitle => 'Ilaina ny fahazoan-dalana';

  @override
  String get permissionNeededBody =>
      'Mila io fahazoan-dalana io i Hafatra mba hampita hafatra. Afaka manohy tsy misy azy ianao, fa ho voafetra ny fifandraisana.';

  @override
  String get notNowLabel => 'Aoriana';

  @override
  String get allowLabel => 'Avelao';

  @override
  String onboardingStep(int current, int total) {
    return 'Dingana $current amin\'ny $total';
  }

  @override
  String get onboardingDemoHint =>
      'Afaka manova ny fomba fotoana rehetra ao amin\'ny fikirana ianao.';

  @override
  String get neighborhoodCodeTooShort =>
      'Tokony manana litera 3 farafahakeliny ny kaody.';

  @override
  String get backgroundNotificationText =>
      'Mandeha ny relay — mifindra eo amin\'ny telefaona ny hafatrao.';

  @override
  String get backgroundNotificationDemoText =>
      'Mandeha ny simulation — tambajotra fanandramana.';

  @override
  String get demoWelcomeMessage =>
      'Tongasoa eto Hafatra! Avy amin\'ny mpifanila trano simulation ity hafatra ity. Manorata hanandramana ny fifandraisana.';

  @override
  String get permissionBluetoothMissing =>
      'Avelao ny Bluetooth mba handehanan\'ny relay tena izy.';

  @override
  String get permissionsSkipHint =>
      'Afaka mamela ireo fahazoan-dalana ireo ao amin\'ny fikirana ianao any aoriana.';

  @override
  String get sendingLabel => 'Mandefa…';

  @override
  String get chatYou => 'Hianao';

  @override
  String get chatMessageRetentionHint =>
      'Mijanona 30 andro ao amin\'ity telefaona ity ny hafatra.';

  @override
  String get copyChannelCode => 'Adikao ny kaody';

  @override
  String get channelCodeCopied => 'Voadika ny kaody faritra.';

  @override
  String get meshStarting => 'Manomboka…';

  @override
  String get meshStopping => 'Mijanona…';

  @override
  String get meshError => 'Nisy olana';

  @override
  String get meshUnavailable => 'Tsy misy';

  @override
  String get meshRefresh => 'Havaozina';

  @override
  String get meshPermissionMissing =>
      'Tsy navela ny Bluetooth. Sokafy ny fahazoan-dalana mba handehanan\'ny relay tena izy.';

  @override
  String get meshOpenPermissions => 'Sokafy ny fahazoan-dalana';

  @override
  String get meshStartHint =>
      'Manomboka ho azy ny relay rehefa vita ny fanolorana. Afaka mamerina azy eto ianao.';

  @override
  String get meshTestSent =>
      'Nampidirina tamin\'ny filaharana ny hafatra fanandramana.';

  @override
  String meshLastError(String error) {
    return 'Olana farany: $error';
  }

  @override
  String get meshBatteryCritical => 'Najanonana ny relay: latsaka ny batterie.';

  @override
  String get meshDemoNotice =>
      'Mode fanandramana: simulation eto amin\'ity telefaona ity ny mpifanila trano sy ny valiny.';

  @override
  String get meshThresholdHelp =>
      'Raha latsaka noho io ny batterie dia tsy mampita hafatra hafa intsony i Hafatra.';

  @override
  String meshStartedAt(String time) {
    return 'Mandeha nanomboka $time';
  }

  @override
  String get meshNoPeersHint =>
      'Ampio akaiky ny telefaoninao ny telefaona hafa misy Hafatra.';

  @override
  String get settingsProfile => 'Mombamomba';

  @override
  String get settingsAppearance => 'Endrika';

  @override
  String get settingsMesh => 'Fifandraisana';

  @override
  String get settingsDemoMode => 'Mode fanandramana';

  @override
  String get settingsDemoWarning =>
      'Maka ny toeran\'ny Bluetooth tena izy ny simulation. Ajanony izy raha hanandramana amin\'ny telefaona maro.';

  @override
  String get settingsBatteryThresholdHelp =>
      'Mijanona ny relay raha latsaka noho io ny batterie, afa-tsy raha mampiditra herinaratra ny telefaona.';

  @override
  String get settingsPermissionsBody =>
      'Ireo fahazoan-dalana ireo no ahafahana mampita hafatra sy mampiseho fampitandremana.';

  @override
  String get settingsOpenSystemSettings => 'Sokafy ny fikirana Android';

  @override
  String get settingsChangeName => 'Ovay';

  @override
  String get settingsNameUpdated => 'Voaova ny anarana.';

  @override
  String get settingsNameDialogTitle => 'Anarana aseho';

  @override
  String get settingsSaveLabel => 'Tehirizo';

  @override
  String get cancelLabel => 'Ajanona';

  @override
  String get diagnosticsSystem => 'Rafitra';

  @override
  String get diagnosticsAppVersion => 'Application';

  @override
  String get diagnosticsPlatform => 'Fitaovana';

  @override
  String get diagnosticsDatabaseOk => 'Misokatra';

  @override
  String get diagnosticsDatabaseError => 'Nisy olana';

  @override
  String get diagnosticsAlertTools => 'Fitaovana fampitandremana';

  @override
  String diagnosticsAlertRejected(String reason) {
    return 'Nolaviny ny fampitandremana: $reason.';
  }

  @override
  String get diagnosticsAlertAdded =>
      'Voamarina sy nalefa ny fampitandremana fanandramana.';

  @override
  String get diagnosticsLogsHint =>
      'Tsy misy votoatin\'ny hafatra na mombamomba azy ao amin\'ny logs.';

  @override
  String get diagnosticsPermissions => 'Fahazoan-dalana';

  @override
  String get alertDetailsTitle => 'Antsipiriany ny fampitandremana';

  @override
  String alertIssued(String date) {
    return 'Navoaka ny $date';
  }

  @override
  String alertArea(String area) {
    return 'Faritra: $area';
  }

  @override
  String alertSignature(String fingerprint) {
    return 'Dian-tanana: $fingerprint';
  }

  @override
  String get alertDemoBadge => 'Fanandramana';

  @override
  String get alertDemoHint =>
      'Afaka mampiditra fampitandremana fanandramana ao amin\'ny Diagnostics ianao.';

  @override
  String get aboutPrivacy =>
      'Tsy misy votoatin\'ny hafatra alefa amin\'ny serivera. Mijanona ao amin\'ny telefaona ny mombamomba sy ny fanalahidy.';

  @override
  String get aboutOffline =>
      'Miasa tsy misy Internet aloha, natao ho an\'i Madagasikara.';

  @override
  String get aboutPublicChannel =>
      'Ampahibemaso ny efitrano faritra: aza mizara vaovao saro-pady.';

  @override
  String get unknownLabel => 'Tsy fantatra';

  @override
  String get onLabel => 'Mandeha';

  @override
  String get offLabel => 'Tapaka';

  @override
  String get serviceLabel => 'Serivisy';

  @override
  String get databaseLabel => 'Tahiry eo an-toerana';

  @override
  String get refreshLabel => 'Havaozina';

  @override
  String get loadingLabel => 'Eo am-pakàna…';

  @override
  String get notAvailableLabel => 'Tsy misy';

  @override
  String get alertInjectionError =>
      'Tsy afaka nampiditra ny fampitandremana fanandramana.';

  @override
  String get openDiagnostics => 'Sokafy ny diagnostics';

  @override
  String get errorMeshNotReady =>
      'Tsy vonona ny fifandraisana. Hamarino ny fahazoan-dalana ary avereno ny relay.';

  @override
  String channelLabel(String code) {
    return 'Efitrano: $code';
  }

  @override
  String relayCounts(int relay, int seen) {
    return 'Nampitaina tamin\'ny $relay · hita tamin\'ny $seen';
  }

  @override
  String get messageStatusHint =>
      'Miandry = voatahiry eto amin\'ity telefaona ity. Nalefa = tonga tamin\'ny fitaovana akaiky.';

  @override
  String get demoTag => 'Démo';

  @override
  String get bleTag => 'BLE';

  @override
  String get transportLabel => 'Fifandraisana';
}
