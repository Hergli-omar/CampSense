import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';

// ============================================================================
// CONTRAT D'ARCHITECTURE INTER-MODULES :
// Les autres modules (Event, Marketplace, Transport, Tutorial, Campsite)
// n'importent QUE ce fichier `user_api.dart`.
// Ils ne doivent JAMAIS importer les providers, repositories ou écrans internes
// du module User.
// ============================================================================

export 'models/user.dart' show User;

/// Rôles supportés par l'application CampSense.
class UserRoles {
  static const String camper = 'camper';
  static const String organizer = 'organizer';
  static const String admin = 'admin';

  static const List<String> assignableRoles = [camper, organizer];
}

/// Extension facilitant l'accès au profil et à la session utilisateur
/// depuis n'importe quel widget des autres modules sans couplage fort.
extension UserContextX on BuildContext {
  /// Utilisateur actuellement connecté, ou null s'il s'agit d'un visiteur.
  User? get currentUser {
    try {
      return watch<AuthProvider>().currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Identifiant unique (id SQLite) de l'utilisateur connecté.
  int? get currentUserId => currentUser?.id;

  /// Rôle de l'utilisateur connecté ('camper', 'organizer', 'admin') ou null.
  String? get currentUserRole => currentUser?.role;

  /// Indique si un utilisateur est actuellement authentifié.
  bool get isLoggedIn => currentUser != null;

  /// Indique si l'utilisateur connecté a les droits d'administration.
  bool get isAdmin => currentUser?.isAdmin ?? false;
}

/// Widget réutilisable par les autres modules :
/// Affiche [child] uniquement si un utilisateur est connecté.
/// Sinon, affiche [fallback] ou un conteneur vide par défaut.
class RequireLogin extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const RequireLogin({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isLoggedIn) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
