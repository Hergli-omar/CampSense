import 'package:flutter/material.dart';

/// Extension de couleurs sémantiques CampSense pour le thème clair et sombre.
/// Permet à tous les modules d'accéder aux couleurs de tuiles, cartes, alertes, etc.
class CampSenseColors extends ThemeExtension<CampSenseColors> {
  final Color background;
  final Color card;
  final Color cardBorder;
  final Color primary;
  final Color primaryText;
  final Color title;
  final Color tile;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color amberBackground;
  final Color amberText;
  final Color danger;
  final Color dangerTile;
  final Color success;

  const CampSenseColors({
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.primary,
    required this.primaryText,
    required this.title,
    required this.tile,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.amberBackground,
    required this.amberText,
    required this.danger,
    required this.dangerTile,
    required this.success,
  });

  @override
  ThemeExtension<CampSenseColors> copyWith({
    Color? background,
    Color? card,
    Color? cardBorder,
    Color? primary,
    Color? primaryText,
    Color? title,
    Color? tile,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? amberBackground,
    Color? amberText,
    Color? danger,
    Color? dangerTile,
    Color? success,
  }) {
    return CampSenseColors(
      background: background ?? this.background,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      primary: primary ?? this.primary,
      primaryText: primaryText ?? this.primaryText,
      title: title ?? this.title,
      tile: tile ?? this.tile,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      amberBackground: amberBackground ?? this.amberBackground,
      amberText: amberText ?? this.amberText,
      danger: danger ?? this.danger,
      dangerTile: dangerTile ?? this.dangerTile,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<CampSenseColors> lerp(
    covariant ThemeExtension<CampSenseColors>? other,
    double t,
  ) {
    if (other is! CampSenseColors) return this;
    return CampSenseColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      title: Color.lerp(title, other.title, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      amberBackground: Color.lerp(amberBackground, other.amberBackground, t)!,
      amberText: Color.lerp(amberText, other.amberText, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerTile: Color.lerp(dangerTile, other.dangerTile, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
