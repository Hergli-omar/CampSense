import 'package:flutter/material.dart';
import 'camp_sense_colors.dart';

/// Extension de commodité sur [BuildContext] pour accéder facilement
/// aux couleurs sémantiques et styles typographiques du Design System.
///
/// Exemple d'utilisation dans n'importe quel widget ou module :
/// ```dart
/// final bg = context.colors.card;
/// final titleColor = context.colors.title;
/// final textStyle = context.text.headlineMedium;
/// ```
extension ThemeX on BuildContext {
  /// Accès direct au thème courant.
  ThemeData get theme => Theme.of(this);

  /// Palette sémantique de couleurs CampSense (light / dark).
  CampSenseColors get colors =>
      theme.extension<CampSenseColors>() ?? _defaultFallbackColors;

  /// Accès direct aux styles typographiques configurés.
  TextTheme get text => theme.textTheme;

  /// Indique si le thème actuel est en mode sombre.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  static const CampSenseColors _defaultFallbackColors = CampSenseColors(
    background: Color(0xFFF4F2EC),
    card: Color(0xFFFDFCF8),
    cardBorder: Color(0xFFE4E1D6),
    primary: Color(0xFF244C3B),
    primaryText: Colors.white,
    title: Color(0xFF1F3D31),
    tile: Color(0xFFE5ECE1),
    textPrimary: Color(0xFF1C2420),
    textSecondary: Color(0xFF6F766F),
    accent: Color(0xFFA9482A),
    amberBackground: Color(0xFFF5E8CC),
    amberText: Color(0xFF8A5A12),
    danger: Color(0xFFA63A30),
    dangerTile: Color(0xFFF8E2DC),
    success: Color(0xFF2E7D32),
  );
}
