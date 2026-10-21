import 'package:flutter/material.dart';

enum AppThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  AppThemePreference(this.storageValue);

  final String storageValue;

  ThemeMode get themeMode => switch (this) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  static AppThemePreference fromStorage(String? value) {
    return values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

final class AppSettings {
  const AppSettings({
    required this.localeCode,
    required this.theme,
    required this.relayEnabled,
    required this.batteryThreshold,
    required this.demoMode,
  });

  factory AppSettings.defaults() => const AppSettings(
    localeCode: 'fr',
    theme: AppThemePreference.system,
    relayEnabled: true,
    batteryThreshold: 15,
    demoMode: false,
  );

  final String localeCode;
  final AppThemePreference theme;
  final bool relayEnabled;
  final int batteryThreshold;
  final bool demoMode;

  AppSettings copyWith({
    String? localeCode,
    AppThemePreference? theme,
    bool? relayEnabled,
    int? batteryThreshold,
    bool? demoMode,
  }) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      theme: theme ?? this.theme,
      relayEnabled: relayEnabled ?? this.relayEnabled,
      batteryThreshold: batteryThreshold ?? this.batteryThreshold,
      demoMode: demoMode ?? this.demoMode,
    );
  }
}
