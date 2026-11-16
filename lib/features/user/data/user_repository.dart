import '../models/stay.dart';
import '../models/user.dart';

/// Abstract contract for user account and stays data operations.
/// Completely decouples data persistence from UI and state management.
/// Can be cleanly substituted with a Firebase or remote API repository in the future.
abstract class UserRepository {
  /// Fetches a user by their primary ID.
  Future<User?> getUserById(int id);

  /// Fetches a user by their unique email.
  Future<User?> getUserByEmail(String email);

  /// Creates a new user record and returns the persisted instance with ID.
  Future<User> createUser(User user);

  /// Updates existing user details and returns the number of rows affected.
  Future<int> updateUser(User user);

  /// Permanently deletes a user and cascades to associated stays.
  Future<int> deleteUser(int id);

  /// Checks if an email address is already in use by another account.
  Future<bool> emailExists(String email, {int? excludeUserId});

  // --- STAYS (temporary until Event module integration) ---

  /// Fetches all stays recorded for a specific user, sorted by start_date DESC.
  Future<List<Stay>> getStaysForUser(int userId);

  /// Adds a new stay for a user.
  Future<Stay> addStay(Stay stay);

  /// Deletes a specific stay by its primary key.
  Future<int> deleteStay(int stayId);

  /// Returns total count of stays for a user (used for account deletion confirmation).
  Future<int> getStaysCountForUser(int userId);

  // --- ADMINISTRATION METHODS ---

  /// Fetches all non-admin users matching optional search query and role filter.
  /// Results are sorted alphabetically by full_name.
  Future<List<User>> getAllUsers({String? query, String? role});

  /// Returns count of users grouped by role ('camper', 'organizer').
  /// Strictly excludes admin accounts.
  Future<Map<String, int>> countByRole();

  /// Creates a camper or organizer account on behalf of the administrator.
  /// Rejects creation if the requested role is 'admin'.
  Future<User> createUserByAdmin(User user);

  /// Updates a user account through the admin interface.
  /// Rejects updating if target is an admin.
  Future<int> updateUserByAdmin(User user);

  /// Deletes a user account through the admin interface.
  /// Rejects deletion if target is an admin.
  Future<int> deleteUserByAdmin(int id);

  /// Returns the number of stays associated with a user ID.
  Future<int> getStayCount(int userId);
}

/// Thrown when an unauthorized or forbidden action is attempted on the repository.
class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
