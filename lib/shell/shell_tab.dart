import 'package:flutter/material.dart';

/// Configuration definition for a navigation tab in [AppShell].
///
/// NOTE FOR MODULE INTEGRATION:
/// To integrate a module (e.g. Sorties, Matériel, Trajets, Guides, Camp),
/// replace the [builder] closure with the root screen widget of that module.
///
/// RECHERCHE PAR MODULE :
/// Chaque coéquipier peut brancher sa propre recherche plus tard en définissant :
/// - [onSearch] : callback déclenché lors du clic sur la loupe dans l'AppBar.
/// - [searchHint] : libellé indicatif pour le champ de recherche du module.
class ShellTab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function(BuildContext context) builder;
  final VoidCallback? onSearch;
  final String? searchHint;

  const ShellTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
    this.onSearch,
    this.searchHint,
  });
}
