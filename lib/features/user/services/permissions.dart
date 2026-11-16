import '../models/user.dart';

/// Centralized security and permissions manager for CampSense.
///
/// Ensures role boundaries are strictly enforced throughout the app.
///
/// NOTE ON SECURITY:
/// Because CampSense currently runs with a local SQLite database without a backend,
/// permissions are verified in the app layer (repositories, providers, and UI).
/// When migrating to Firebase, these rules should be replicated in Firebase
/// Security Rules on Cloud Firestore / Realtime Database.
class Permissions {
  /// Allowed roles that can be selected or assigned from the user interface.
  /// The 'admin' role is STRICTLY prohibited from being assigned via UI forms.
  static const List<String> assignableRoles = ['camper', 'organizer'];

  /// Verifies if a role string can be assigned through forms.
  static bool isAssignableRole(String role) {
    return assignableRoles.contains(role.trim().toLowerCase());
  }

  /// Verifies whether the actor can access the administration shell and features.
  static bool canAccessAdminArea(User? actor) {
    return actor != null && actor.isAdmin;
  }

  /// Verifies whether the actor is allowed to view the member directory.
  static bool canViewUserList(User? actor) {
    return actor != null && actor.isAdmin;
  }

  /// Verifies whether the actor can view a target user's details.
  static bool canViewUser(User? actor, User target) {
    if (actor == null) return false;
    if (actor.isAdmin) return true;
    return actor.id != null && actor.id == target.id;
  }

  /// Verifies whether the actor can create an account with [targetRole].
  /// Admins can create campers and organizers. Nobody can create an admin via UI.
  static bool canCreateUser(User? actor, String targetRole) {
    if (actor == null || !actor.isAdmin) return false;
    return isAssignableRole(targetRole);
  }

  /// Verifies whether the actor can update the [target] user account.
  /// - Admins can update campers and organizers, but NEVER admin accounts (including self via admin UI).
  /// - Regular users can update their own profile.
  static bool canUpdateUser(User? actor, User target) {
    if (actor == null) return false;
    if (actor.isAdmin) {
      // Admin cannot edit admin accounts in user management
      return !target.isAdmin;
    }
    // Regular users can only edit themselves
    return actor.id != null && actor.id == target.id;
  }

  /// Verifies whether the actor can delete the [target] user account.
  /// - Admins can delete campers and organizers.
  /// - Admins can NEVER delete another admin or their own admin account.
  /// - Regular users can delete their own account from their profile screen.
  static bool canDeleteUser(User? actor, User target) {
    if (actor == null) return false;
    if (actor.isAdmin) {
      if (target.isAdmin) return false;
      if (actor.id != null && target.id != null && actor.id == target.id) {
        return false;
      }
      return true;
    }
    // Regular users delete their own account
    return actor.id != null && actor.id == target.id;
  }
}
