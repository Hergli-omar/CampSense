import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  locked,
}

/// Provider managing authentication state, session lifecycle,
/// and the 30-second lockout timer countdown.
class AuthProvider with ChangeNotifier {
  final AuthService authService;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  int? _lockoutSeconds;
  Timer? _lockoutTimer;

  AuthProvider({required this.authService});

  AuthStatus get status => _status;
  User? get currentUser => authService.currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated && currentUser != null;
  String? get errorMessage => _errorMessage;
  int? get lockoutSeconds => _lockoutSeconds;

  /// Restores session from local storage (used during Splash).
  Future<bool> restoreSession() async {
    // Check if lockout is still active
    final remainingLock = await authService.getRemainingLockoutSeconds();
    if (remainingLock != null) {
      _startLockoutCountdown(remainingLock);
      _status = AuthStatus.locked;
      notifyListeners();
      return false;
    }

    final user = await authService.restoreSession();
    if (user != null) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Attempts to log in with email and password.
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final result = await authService.login(email, password);
    if (result.isSuccess) {
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      if (result.lockoutRemainingSeconds != null) {
        _startLockoutCountdown(result.lockoutRemainingSeconds!);
        _status = AuthStatus.locked;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  /// Registers a new camper account.
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String experienceLevel,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final result = await authService.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      experienceLevel: experienceLevel,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    );

    if (result.isSuccess) {
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  /// Starts or continues active lockout countdown timer.
  void _startLockoutCountdown(int seconds) {
    _lockoutSeconds = seconds;
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutSeconds != null && _lockoutSeconds! > 1) {
        _lockoutSeconds = _lockoutSeconds! - 1;
        notifyListeners();
      } else {
        _lockoutTimer?.cancel();
        _lockoutSeconds = null;
        _status = AuthStatus.unauthenticated;
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  /// Logs out and resets authentication state.
  Future<void> logout() async {
    await authService.logout();
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Permanently deletes account and cascades.
  Future<void> deleteAccount() async {
    await authService.deleteAccount();
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Verifies current user password (e.g. for revealing emergency phone or deleting account).
  Future<bool> verifyCurrentPassword(String secret) async {
    return await authService.verifyCurrentPassword(secret);
  }

  /// Refreshes in-memory user when profile is updated.
  void refreshCurrentUser(User updatedUser) {
    authService.updateCurrentUser(updatedUser);
    notifyListeners();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }
}
