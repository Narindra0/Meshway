import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hafatra/l10n/generated/app_localizations.dart';

export 'package:hafatra/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const List<Locale> supportedLocales = [Locale('fr'), Locale('mg')];

/// Flutter ne fournit pas de `MaterialLocalizations` malgaches. On réutilise
/// les libellés français pour les composants Material/Cupertino intégrés
/// (menus de sélection, accessibilité) tout en gardant les textes Hafatra en
/// malgache.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
      ...AppLocalizations.localizationsDelegates,
      _MalagasyMaterialLocalizationsDelegate(),
      _MalagasyCupertinoLocalizationsDelegate(),
    ];

final class _MalagasyMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MalagasyMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return GlobalMaterialLocalizations.delegate.load(const Locale('fr'));
  }

  @override
  bool shouldReload(_MalagasyMaterialLocalizationsDelegate old) => false;
}

final class _MalagasyCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _MalagasyCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));
  }

  @override
  bool shouldReload(_MalagasyCupertinoLocalizationsDelegate old) => false;
}
