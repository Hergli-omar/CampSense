import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/date_format_fr.dart';
import '../../../core/utils/password_hasher.dart';
import '../data/user_repository.dart';
import '../models/user.dart';
import 'identity_verifier.dart';

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;
  final int? lockoutRemainingSeconds;

  const AuthResult.success(this.user)
      : isSuccess = true,
        errorMessage = null,
        lockoutRemainingSeconds = null;

  const AuthResult.failure(this.errorMessage, {this.lockoutRemainingSeconds})
      : isSuccess = false,
        user = null;
}

/// Authentication and session management service.
/// Coordinates with [UserRepository] and [IdentityVerifier].
/// Implements 30-second lockout after 5 consecutive failed attempts.
class AuthService {
  static const String _keySessionUserId = 'cs_session_user_id';
  static const String _keyFailedAttempts = 'cs_failed_attempts';
  static const String _keyLockoutUntilMs = 'cs_lockout_until_ms';

  static const int maxFailedAttempts = 5;
  static const int lockoutDurationSeconds = 30;

  final UserRepository userRepository;
  final IdentityVerifier identityVerifier;

  User? _currentUser;

  AuthService({
    required this.userRepository,
    this.identityVerifier = const PasswordIdentityVerifier(),
  });

  User? get currentUser => _currentUser;

  /// Loads persisted user session on app start.
  Future<User?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keySessionUserId);
    if (userId == null) {
      _currentUser = null;
      return null;
    }

    final user = await userRepository.getUserById(userId);
    if (user == null) {
      // User was deleted or invalid
      await prefs.remove(_keySessionUserId);
      _currentUser = null;
      return null;
    }

    _currentUser = user;
    return user;
  }

  /// Checks if account login is currently locked due to too many failed attempts.
  Future<int?> getRemainingLockoutSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getInt(_keyLockoutUntilMs);
    if (lockoutUntil == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= lockoutUntil) {
      // Lock expired
      await prefs.remove(_keyLockoutUntilMs);
      await prefs.setInt(_keyFailedAttempts, 0);
      return null;
    }

    final remainingSec = ((lockoutUntil - now) / 1000).ceil();
    return remainingSec > 0 ? remainingSec : null;
  }

  /// Authenticates user with email and password.
  Future<AuthResult> login(String email, String password) async {
    final remainingLock = await getRemainingLockoutSeconds();
    if (remainingLock != null) {
      return AuthResult.failure(
        '${AppStrings.accountLockedMessage} ($remainingLock s)',
        lockoutRemainingSeconds: remainingLock,
      );
    }

    final user = await userRepository.getUserByEmail(email);
    final isValid = user != null && await identityVerifier.verify(user, password);

    final prefs = await SharedPreferences.getInstance();

    if (!isValid) {
      var failed = (prefs.getInt(_keyFailedAttempts) ?? 0) + 1;
      await prefs.setInt(_keyFailedAttempts, failed);

      if (failed >= maxFailedAttempts) {
        final lockUntil = DateTime.now()
            .add(const Duration(seconds: lockoutDurationSeconds))
            .millisecondsSinceEpoch;
        await prefs.setInt(_keyLockoutUntilMs, lockUntil);
        return const AuthResult.failure(
          '${AppStrings.accountLockedMessage} ($lockoutDurationSeconds s)',
          lockoutRemainingSeconds: lockoutDurationSeconds,
        );
      }

      return const AuthResult.failure(AppStrings.genericAuthError);
    }

    // Success: reset lockout counters and save session
    await prefs.remove(_keyFailedAttempts);
    await prefs.remove(_keyLockoutUntilMs);
    await prefs.setInt(_keySessionUserId, user.id!);

    _currentUser = user;
    return AuthResult.success(user);
  }

  /// Registers a new user and persists session.
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String experienceLevel,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final emailLower = email.trim().toLowerCase();
    final exists = await userRepository.emailExists(emailLower);
    if (exists) {
      return const AuthResult.failure(AppStrings.emailAlreadyExists);
    }

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

    final createdUser = await userRepository.createUser(newUser);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessionUserId, createdUser.id!);

    _currentUser = createdUser;
    return AuthResult.success(createdUser);
  }

  /// Verifies current logged in user's identity (e.g. For revealing phone, changing password)
  Future<bool> verifyCurrentPassword(String secret) async {
    if (_currentUser == null) return false;
    return await identityVerifier.verify(_currentUser!, secret);
  }

  /// Updates current user profile and synchronizes state.
  Future<User> updateCurrentUser(User updated) async {
    await userRepository.updateUser(updated);
    _currentUser = updated;
    return updated;
  }

  /// Logs out and clears session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionUserId);
    _currentUser = null;
  }

  /// Deletes account permanently, clears session, and notifies.
  Future<void> deleteAccount() async {
    if (_currentUser?.id != null) {
      await userRepository.deleteUser(_currentUser!.id!);
    }
    await logout();
  }
}
