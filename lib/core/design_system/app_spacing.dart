import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Respiration verticale entre les blocs d'une page.
  static const double sectionGap = 20;

  /// Marge latérale commune à tous les écrans.
  static const double gutter = 20;
}

abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 22;
  static const double xl = 28;
  static const double xxl = 34;
  static const double pill = 999;

  static BorderRadius card() => BorderRadius.circular(lg);

  static BorderRadius sheet() =>
      const BorderRadius.vertical(top: Radius.circular(xl));

  /// Bulle de message : trois coins arrondis, un coin serré côté expéditeur.
  static BorderRadius bubble({required bool outgoing}) {
    return BorderRadius.only(
      topLeft: const Radius.circular(lg),
      topRight: const Radius.circular(lg),
      bottomLeft: Radius.circular(outgoing ? lg : sm),
      bottomRight: Radius.circular(outgoing ? sm : lg),
    );
  }
}

/// Trois niveaux d'élévation, lumière constamment placée en haut à gauche
/// (décalage x positif, y plus grand) : les cartes s'empilent sans bordure.
abstract final class AppElevation {
  const AppElevation._();

  static List<BoxShadow> low(Color shadow) => [
    BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2)),
    BoxShadow(color: shadow, blurRadius: 2, offset: const Offset(1, 1)),
  ];

  static List<BoxShadow> medium(Color shadow) => [
    BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, 6)),
    BoxShadow(color: shadow, blurRadius: 6, offset: const Offset(2, 2)),
  ];

  static List<BoxShadow> high(Color shadow) => [
    BoxShadow(color: shadow, blurRadius: 36, offset: const Offset(0, 14)),
    BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(2, 4)),
  ];

  /// Halo coloré (hero maillage, avatar actif) : la marque remplace le noir.
  static List<BoxShadow> glow(Color glow) => [
    BoxShadow(color: glow, blurRadius: 32, spreadRadius: -6),
  ];
}

/// Durées et courbes des micro-interactions. Toute animation doit passer par là
/// et être neutralisable par [AppMotion.reduceMotion] quand le système demande
/// de réduire les animations.
abstract final class AppMotion {
  static const Duration press = Duration(milliseconds: 120);
  static const Duration reveal = Duration(milliseconds: 180);
  static const Duration emphasized = Duration(milliseconds: 260);
  static const Duration hero = Duration(milliseconds: 380);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve springy = Curves.easeOutBack;

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
