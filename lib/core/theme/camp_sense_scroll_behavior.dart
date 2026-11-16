import 'package:flutter/material.dart';

/// Comportement de défilement personnalisé pour CampSense.
///
/// Désactive l'effet d'étirement natif d'Android 12+ (StretchingOverscrollIndicator)
/// qui déforme et élargit horizontalement et verticalement l'écran et les cartes
/// lorsque l'utilisateur dépasse la limite haute ou basse d'une liste.
///
/// Utilise [ClampingScrollPhysics] pour un arrêt net et propre aux extrémités.
class CampSenseScrollBehavior extends MaterialScrollBehavior {
  const CampSenseScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Retourne le widget enfant directement, sans indicateur d'étirement (stretch)
    // évitant ainsi toute déformation ou élargissement de l'écran.
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Bloque le défilement exactement aux limites (0 et maxScrollExtent)
    // sans effet élastique.
    return const ClampingScrollPhysics();
  }
}
