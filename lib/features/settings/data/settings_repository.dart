import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/features/settings/domain/app_settings.dart';

/// Lecture/écriture des préférences dans la base locale.
final class SettingsRepository {
  SettingsRepository(this._database);

  final AppDatabase _database;

  Future<AppSettings> load() async {
    final values = await _database.getSettings();
    final threshold = int.tryParse(
      values[AppConstants.settingBatteryThreshold] ?? '',
    );
    return AppSettings(
      localeCode:
          values[AppConstants.settingLocale] == AppConstants.localeMalagasy
          ? AppConstants.localeMalagasy
          : AppConstants.localeFrench,
      theme: AppThemePreference.fromStorage(values[AppConstants.settingTheme]),
      relayEnabled: values[AppConstants.settingRelayEnabled] != 'false',
      batteryThreshold: (threshold ?? AppConstants.defaultBatteryThreshold)
          .clamp(
            AppConstants.minBatteryThreshold,
            AppConstants.maxBatteryThreshold,
          ),
      demoMode: values[AppConstants.settingDemoMode] == 'true',
    );
  }

  Future<void> save(AppSettings settings) async {
    await _database.putSetting(AppConstants.settingLocale, settings.localeCode);
    await _database.putSetting(
      AppConstants.settingTheme,
      settings.theme.storageValue,
    );
    await _database.putSetting(
      AppConstants.settingRelayEnabled,
      settings.relayEnabled.toString(),
    );
    await _database.putSetting(
      AppConstants.settingBatteryThreshold,
      settings.batteryThreshold.toString(),
    );
    await _database.putSetting(
      AppConstants.settingDemoMode,
      settings.demoMode.toString(),
    );
  }

  Future<bool> isOnboardingComplete() async {
    return await _database.getSetting(AppConstants.settingOnboardingComplete) ==
        'true';
  }

  Future<void> setOnboardingComplete(bool value) {
    return _database.putSetting(
      AppConstants.settingOnboardingComplete,
      value.toString(),
    );
  }
}
