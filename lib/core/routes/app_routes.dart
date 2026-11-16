import 'package:flutter/material.dart';
import '../../features/user/user_routes.dart';

// ============================================================================
// CONTRAT DE ROUTAGE CENTRALISÉ ET EXTENSION INTER-MODULES
// ============================================================================
// Pour brancher un nouveau module (Event, Marketplace, Transport, Tutorial, Campsite) :
// 1) Créer un fichier `lib/features/<module>/<module>_routes.dart` exposant
//    une `Map<String, WidgetBuilder>`.
// 2) Ajouter cette map à la liste `moduleRoutes` ci-dessous.
// 3) Aucun changement n'est nécessaire dans `app.dart`.
// ============================================================================

/// Constantes des routes fondamentales de CampSense.
class AppRoutes {
  static const String splash = UserRoutes.splash;
  static const String login = UserRoutes.login;
  static const String register = UserRoutes.register;
  static const String shell = UserRoutes.shell;
  static const String adminShell = UserRoutes.adminShell;
  static const String editProfile = UserRoutes.editProfile;
}

/// Routeur global combinant les tables de routage déclarées par chaque module.
class AppRouter {
  /// Registre de toutes les maps de routes fournies par les modules.
  static final List<Map<String, WidgetBuilder>> moduleRoutes = [
    UserRoutes.routes,
    // Exemples d'intégration future :
    // EventRoutes.routes,
    // MarketplaceRoutes.routes,
    // TransportRoutes.routes,
    // TutorialRoutes.routes,
    // CampsiteRoutes.routes,
  ];

  /// Combine l'ensemble des routes déclarées par les différents modules.
  static Map<String, WidgetBuilder> get allRoutes {
    final combined = <String, WidgetBuilder>{};
    for (final routesMap in moduleRoutes) {
      combined.addAll(routesMap);
    }
    return combined;
  }

  /// Générateur de routes dynamique utilisé par MaterialApp.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = allRoutes[settings.name];
    if (builder != null) {
      return MaterialPageRoute<dynamic>(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }
}
