import 'package:flutter/material.dart';

/// Palette de Hafatra : teal profond (confiance), ambre (visibilité) et
/// corail (urgence). Les teintes de marque sont inchangées ; seules les
/// surfaces gagnent en profondeur (cinq niveaux par thème) pour que les
/// cartes, les bulles et la barre de composition se distinguent sans bordure.
abstract final class AppColors {
  // Marques (clair)
  static const Color primary = Color(0xFF0B4F4A);
  static const Color primaryDeep = Color(0xFF06332F);
  static const Color primaryBright = Color(0xFF13796E);
  static const Color primaryContainer = Color(0xFFCFE8E2);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF8A5A00);
  static const Color secondaryContainer = Color(0xFFFFE2A8);
  static const Color tertiary = Color(0xFFC73E1D);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB26A00);
  static const Color error = Color(0xFFB3261E);

  // Surfaces (clair) — rampe papier chaud, du plus haut au plus bas.
  static const Color surface = Color(0xFFEFEEE6);
  static const Color surfaceLowest = Color(0xFFFFFEFB);
  static const Color surfaceLow = Color(0xFFF5F3EC);
  static const Color surfaceHigh = Color(0xFFE8E6DC);
  static const Color surfaceHighest = Color(0xFFDFDCD1);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = surfaceLowest;
  static const Color surfaceContainerHighest = surfaceHighest;

  static const Color ink = Color(0xFF141C1A);
  static const Color inkMuted = Color(0xFF4E5C58);
  static const Color outline = Color(0xFF6F7B78);

  // Marques (sombre)
  static const Color darkPrimary = Color(0xFF7FD1C7);
  static const Color darkPrimaryContainer = Color(0xFF0F3B37);
  static const Color darkSecondary = Color(0xFFFFC857);
  static const Color darkTertiary = Color(0xFFFFB4A2);
  static const Color darkError = Color(0xFFF2B8B5);

  // Surfaces (sombre) — encre teintée teal, cinq niveaux distincts.
  static const Color darkSurface = Color(0xFF101D1A);
  static const Color darkSurfaceLowest = Color(0xFF05100E);
  static const Color darkSurfaceLow = Color(0xFF0A1614);
  static const Color darkSurfaceHigh = Color(0xFF172623);
  static const Color darkSurfaceHighest = Color(0xFF1F312D);
  static const Color darkInk = Color(0xFFE6EFEC);
  static const Color darkInkMuted = Color(0xFFA3B2AD);
  static const Color darkOutline = Color(0xFF8A9692);

  static final ColorScheme lightScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: const Color(0xFF062B28),
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: const Color(0xFF2A1B00),
        tertiary: tertiary,
        onTertiary: Colors.white,
        surface: surface,
        onSurface: ink,
        onSurfaceVariant: inkMuted,
        surfaceContainer: surfaceContainer,
        surfaceContainerLowest: surfaceLowest,
        surfaceContainerLow: surfaceLow,
        surfaceContainerHigh: surfaceHigh,
        outline: outline,
        outlineVariant: const Color(0xFFCFCBC0),
        error: error,
        onError: Colors.white,
      );

  static final ColorScheme darkScheme =
      ColorScheme.fromSeed(
        seedColor: darkPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: darkPrimary,
        onPrimary: const Color(0xFF062B28),
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: const Color(0xFFC4F0E9),
        secondary: darkSecondary,
        onSecondary: const Color(0xFF2A1B00),
        secondaryContainer: const Color(0xFF5C4200),
        onSecondaryContainer: const Color(0xFFFFE2A8),
        tertiary: darkTertiary,
        onTertiary: const Color(0xFF5F1607),
        surface: darkSurface,
        onSurface: darkInk,
        onSurfaceVariant: darkInkMuted,
        surfaceContainer: darkSurface,
        surfaceContainerLowest: darkSurfaceLowest,
        surfaceContainerLow: darkSurfaceLow,
        surfaceContainerHigh: darkSurfaceHigh,
        outline: darkOutline,
        outlineVariant: const Color(0xFF33443F),
        error: darkError,
        onError: const Color(0xFF601410),
      );
}

/// Cinq niveaux de surface + filets et ombres, exposés au thème.
///
/// Le fil conducteur du redesign : la profondeur vient de la rampe et d'une
/// ombre portée unique (lumière en haut à gauche), jamais d'une bordure.
final class AppSurfaces extends ThemeExtension<AppSurfaces> {
  const AppSurfaces({
    required this.lowest,
    required this.low,
    required this.base,
    required this.high,
    required this.highest,
    required this.card,
    required this.field,
    required this.hairline,
    required this.hairlineStrong,
    required this.shadow,
    required this.glow,
  });

  final Color lowest;
  final Color low;
  final Color base;
  final Color high;
  final Color highest;

  /// Fond des cartes, feuilles et bulles entrantes : toujours au-dessus de la
  /// page, en clair comme en sombre.
  final Color card;

  /// Fond des champs de saisie et des pastilles : en retrait sous la page.
  final Color field;
  final Color hairline;
  final Color hairlineStrong;
  final Color shadow;
  final Color glow;

  static const AppSurfaces light = AppSurfaces(
    lowest: AppColors.surfaceLowest,
    low: AppColors.surfaceLow,
    base: AppColors.surface,
    high: AppColors.surfaceHigh,
    highest: AppColors.surfaceHighest,
    card: AppColors.surfaceLowest,
    field: AppColors.surfaceHighest,
    hairline: Color(0x14141C1A),
    hairlineStrong: Color(0x24141C1A),
    shadow: Color(0x14092E2A),
    glow: Color(0x1F0B4F4A),
  );

  static const AppSurfaces dark = AppSurfaces(
    lowest: AppColors.darkSurfaceLowest,
    low: AppColors.darkSurfaceLow,
    base: AppColors.darkSurface,
    high: AppColors.darkSurfaceHigh,
    highest: AppColors.darkSurfaceHighest,
    card: AppColors.darkSurfaceHigh,
    field: AppColors.darkSurfaceHighest,
    hairline: Color(0x1AE6EFEC),
    hairlineStrong: Color(0x2BE6EFEC),
    shadow: Color(0x80000000),
    glow: Color(0x3313796E),
  );

  @override
  AppSurfaces copyWith({
    Color? lowest,
    Color? low,
    Color? base,
    Color? high,
    Color? highest,
    Color? card,
    Color? field,
    Color? hairline,
    Color? hairlineStrong,
    Color? shadow,
    Color? glow,
  }) {
    return AppSurfaces(
      lowest: lowest ?? this.lowest,
      low: low ?? this.low,
      base: base ?? this.base,
      high: high ?? this.high,
      highest: highest ?? this.highest,
      card: card ?? this.card,
      field: field ?? this.field,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      shadow: shadow ?? this.shadow,
      glow: glow ?? this.glow,
    );
  }

  @override
  AppSurfaces lerp(AppSurfaces? other, double t) {
    if (other == null) return this;
    return AppSurfaces(
      lowest: Color.lerp(lowest, other.lowest, t)!,
      low: Color.lerp(low, other.low, t)!,
      base: Color.lerp(base, other.base, t)!,
      high: Color.lerp(high, other.high, t)!,
      highest: Color.lerp(highest, other.highest, t)!,
      card: Color.lerp(card, other.card, t)!,
      field: Color.lerp(field, other.field, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

/// Dégradés de marque : bulles sortantes, boutons pleins, hero maillage.
final class AppGradients extends ThemeExtension<AppGradients> {
  const AppGradients({
    required this.brand,
    required this.brandSoft,
    required this.hero,
    required this.sheen,
    required this.brandInk,
  });

  final LinearGradient brand;
  final LinearGradient brandSoft;
  final LinearGradient hero;
  final LinearGradient sheen;

  /// Encre posée sur un dégradé de marque. Les fonds `brand` et `hero`
  /// restent teal foncé dans les deux thèmes : `scheme.onPrimary`, lui,
  /// s'inverse et rendrait le texte illisible en sombre.
  final Color brandInk;

  static const AppGradients light = AppGradients(
    brand: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primaryBright, AppColors.primary],
    ),
    brandSoft: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE3F2EE), Color(0xFFCFE8E2)],
    ),
    hero: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.primaryDeep],
    ),
    sheen: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
    ),
    brandInk: Color(0xFFF2FBF8),
  );

  static const AppGradients dark = AppGradients(
    brand: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F6E63), Color(0xFF0C5C55)],
    ),
    brandSoft: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF16302B), Color(0xFF0F241F)],
    ),
    hero: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF10514B), Color(0xFF06221F)],
    ),
    sheen: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
    ),
    brandInk: Color(0xFFEAFBF6),
  );

  @override
  AppGradients copyWith({
    LinearGradient? brand,
    LinearGradient? brandSoft,
    LinearGradient? hero,
    LinearGradient? sheen,
    Color? brandInk,
  }) {
    return AppGradients(
      brand: brand ?? this.brand,
      brandSoft: brandSoft ?? this.brandSoft,
      hero: hero ?? this.hero,
      sheen: sheen ?? this.sheen,
      brandInk: brandInk ?? this.brandInk,
    );
  }

  @override
  AppGradients lerp(AppGradients? other, double t) {
    if (other == null) return this;
    return AppGradients(
      brand: LinearGradient.lerp(brand, other.brand, t)!,
      brandSoft: LinearGradient.lerp(brandSoft, other.brandSoft, t)!,
      hero: LinearGradient.lerp(hero, other.hero, t)!,
      sheen: LinearGradient.lerp(sheen, other.sheen, t)!,
      brandInk: Color.lerp(brandInk, other.brandInk, t)!,
    );
  }
}

/// Raccourcis de lecture du thème étendu.
extension AppThemeX on BuildContext {
  AppSurfaces get surfaces => Theme.of(this).extension<AppSurfaces>()!;

  AppGradients get gradients => Theme.of(this).extension<AppGradients>()!;
}
