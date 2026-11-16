import 'package:flutter/foundation.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/date_format_fr.dart';
import '../../../core/utils/password_hasher.dart';
import '../data/user_repository.dart';
import '../models/user.dart';
import '../services/identity_verifier.dart';
import '../services/permissions.dart';

/// Provider managing admin user list, filters, role counters,
/// and CRUD operations on behalf of the administrator.
class AdminUsersProvider with ChangeNotifier {
  final UserRepository userRepository;
  final IdentityVerifier identityVerifier;

  List<User> _users = [];
  Map<String, int> _counts = {'camper': 0, 'organizer': 0};
  String _searchQuery = '';
  String _selectedRole = 'all'; // 'all' | 'camper' | 'organizer'
  bool _isLoading = false;
  String? _errorMessage;

  AdminUsersProvider({
    required this.userRepository,
    this.identityVerifier = const PasswordIdentityVerifier(),
  });

  List<User> get users => List.unmodifiable(_users);
  Map<String, int> get counts => Map.unmodifiable(_counts);
  int get camperCount => _counts['camper'] ?? 0;
  int get organizerCount => _counts['organizer'] ?? 0;
  String get searchQuery => _searchQuery;
  String get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads users and role counts according to current filters.
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final roleFilter = _selectedRole == 'all' ? null : _selectedRole;
      _users = await userRepository.getAllUsers(
        query: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        role: roleFilter,
      );
      _counts = await userRepository.countByRole();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates live search query and refreshes list.
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    loadUsers();
  }

  /// Updates active role filter ('all', 'camper', 'organizer') and refreshes list.
  void setRoleFilter(String role) {
    if (_selectedRole == role) return;
    _selectedRole = role;
    loadUsers();
  }

  /// Clears active search query.
  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    loadUsers();
  }

  /// Creates a new camper or organizer account on behalf of the administrator.
  Future<bool> createUser({
    required User adminUser,
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String experienceLevel,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    if (!Permissions.canCreateUser(adminUser, role)) {
      _errorMessage = AppStrings.unauthorizedAccess;
      notifyListeners();
      return false;
    }

    final emailLower = email.trim().toLowerCase();
    final exists = await userRepository.emailExists(emailLower);
    if (exists) {
      _errorMessage = AppStrings.emailAlreadyExists;
      notifyListeners();
      return false;
    }

    try {
      final salt = PasswordHasher.generateSalt();
      final passwordHash = PasswordHasher.hashPassword(password, salt);
      final nowIso = DateFormatFr.toIso(DateTime.now());

      final newUser = User(
        fullName: fullName.trim(),
        email: emailLower,
        passwordHash: passwordHash,
        salt: salt,
        role: role,
        experienceLevel: experienceLevel,
        emergencyContactName: emergencyContactName?.trim().isNotEmpty == true
            ? emergencyContactName!.trim()
            : null,
        emergencyContactPhone: emergencyContactPhone?.trim().isNotEmpty == true
            ? emergencyContactPhone!.trim()
            : null,
        createdAt: nowIso,
        updatedAt: nowIso,
      );

      await userRepository.createUserByAdmin(newUser);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Updates existing user account.
  Future<bool> updateUser({
    required User adminUser,
    required User updatedUser,
  }) async {
    if (!Permissions.canUpdateUser(adminUser, updatedUser)) {
      _errorMessage = AppStrings.cannotModifyAdmin;
      notifyListeners();
      return false;
    }

    // Verify email uniqueness if changed
    final emailLower = updatedUser.email.trim().toLowerCase();
    final exists = await userRepository.emailExists(
      emailLower,
      excludeUserId: updatedUser.id,
    );
    if (exists) {
      _errorMessage = AppStrings.emailAlreadyExists;
      notifyListeners();
      return false;
    }

    try {
      final nowIso = DateFormatFr.toIso(DateTime.now());
      final userToSave = updatedUser.copyWith(
        email: emailLower,
        updatedAt: nowIso,
      );

      await userRepository.updateUserByAdmin(userToSave);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Deletes a user account after verifying admin password via [IdentityVerifier].
  Future<bool> deleteUser({
    required User adminUser,
    required User targetUser,
    required String adminPassword,
  }) async {
    if (!Permissions.canDeleteUser(adminUser, targetUser)) {
      _errorMessage = AppStrings.cannotDeleteSelf;
      notifyListeners();
      return false;
    }

    final isPasswordValid =
        await identityVerifier.verify(adminUser, adminPassword);
    if (!isPasswordValid) {
      _errorMessage = AppStrings.incorrectPassword;
      notifyListeners();
      return false;
    }

    try {
      await userRepository.deleteUserByAdmin(targetUser.id!);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Returns total stays count for a user.
  Future<int> getStayCount(int userId) async {
    return await userRepository.getStayCount(userId);
  }
}
