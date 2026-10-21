/// Constantes applicatives partagées.
abstract final class AppConstants {
  static const String appName = 'Hafatra';
  static const String applicationId = 'mg.hafatra';

  /// Code de quartier proposé par défaut pendant l'onboarding.
  static const String defaultChannelCode = 'HAFATRA';

  /// 512 octets UTF-8 de contenu utile, hors enveloppe et signature.
  static const int maxMessageBytes = 512;
  static const int maxDisplayNameLength = 40;
  static const int minChannelCodeLength = 3;
  static const int maxChannelCodeLength = 32;

  static const Duration messageRetention = Duration(days: 30);
  static const Duration purgeInterval = Duration(hours: 1);
  static const Duration outboxRetryBase = Duration(seconds: 4);
  static const Duration outboxRetryMax = Duration(minutes: 5);
  static const Duration messageLifetime = Duration(days: 7);
  static const Duration seenPacketLifetime = Duration(days: 7);

  static const int defaultBatteryThreshold = 15;
  static const int minBatteryThreshold = 5;
  static const int maxBatteryThreshold = 40;

  static const String localeFrench = 'fr';
  static const String localeMalagasy = 'mg';
  static const String defaultLocale = localeFrench;

  static const String settingLocale = 'locale';
  static const String settingTheme = 'theme';
  static const String settingRelayEnabled = 'relay_enabled';
  static const String settingBatteryThreshold = 'battery_threshold';
  static const String settingDemoMode = 'demo_mode';
  static const String settingOnboardingComplete = 'onboarding_complete';
  static const String settingBackgroundAssistantSeen =
      'background_assistant_seen';

  static const int outgoingDirection = 1;
  static const int incomingDirection = 0;
}
