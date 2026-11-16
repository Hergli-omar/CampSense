import 'package:flutter/foundation.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/date_format_fr.dart';
import '../../../core/utils/password_hasher.dart';
import '../data/user_repository.dart';
import '../models/stay.dart';
import '../models/user.dart';
import '../services/identity_verifier.dart';

/// Provider handling user profile details, emergency contact display state,
/// and stays history management.
class UserProvider with ChangeNotifier {
  final UserRepository userRepository;
  final IdentityVerifier identityVerifier;

  List<Stay> _stays = [];
  bool _isLoadingStays = false;
  bool _isEmergencyPhoneRevealed = false;

  UserProvider({
    required this.userRepository,
    this.identityVerifier = const PasswordIdentityVerifier(),
  });

  List<Stay> get stays => _stays;
  bool get isLoadingStays => _isLoadingStays;
  bool get isEmergencyPhoneRevealed => _isEmergencyPhoneRevealed;

  /// Loads stays for a given user ID.
  Future<void> loadStays(int userId) async {
    _isLoadingStays = true;
    notifyListeners();

    try {
      _stays = await userRepository.getStaysForUser(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading stays: $e');
      }
    } finally {
      _isLoadingStays = false;
      notifyListeners();
    }
  }

  /// Adds a new stay for demo testing.
  Future<Stay?> addStay({
    required int userId,
    required String placeName,
    required String startDate,
    required String endDate,
    String? notes,
  }) async {
    try {
      final newStay = Stay(
        userId: userId,
        placeName: placeName.trim(),
        startDate: startDate,
        endDate: endDate,
        notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
      );
      final created = await userRepository.addStay(newStay);
      _stays.insert(0, created);
      // Keep sorted by date
      _stays.sort((a, b) => b.startDate.compareTo(a.startDate));
      notifyListeners();
      return created;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding stay: $e');
      }
      return null;
    }
  }

  /// Deletes a stay by ID.
  Future<bool> deleteStay(int stayId) async {
    try {
      await userRepository.deleteStay(stayId);
      _stays.removeWhere((s) => s.id == stayId);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting stay: $e');
      }
      return false;
    }
  }

  /// Reveals emergency contact phone number after successful identity verification.
  void revealEmergencyPhone() {
    _isEmergencyPhoneRevealed = true;
    notifyListeners();
  }

  /// Hides emergency phone number (default safe state, or on screen exit).
  void hideEmergencyPhone() {
    _isEmergencyPhoneRevealed = false;
    notifyListeners();
  }

  /// Updates profile details (name, email, role, experience, emergency contact).
  Future<User> updateProfile({
    required User currentUser,
    required String fullName,
    required String email,
    required String role,
    required String experienceLevel,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final emailLower = email.trim().toLowerCase();
    final exists = await userRepository.emailExists(emailLower, excludeUserId: currentUser.id);
    if (exists) {
      throw Exception(AppStrings.emailAlreadyExists);
    }

    final updated = currentUser.copyWith(
      fullName: fullName.trim(),
      email: emailLower,
      role: role,
      experienceLevel: experienceLevel,
      emergencyContactName: emergencyContactName?.trim().isNotEmpty == true
          ? emergencyContactName!.trim()
          : null,
      emergencyContactPhone: emergencyContactPhone?.trim().isNotEmpty == true
          ? emergencyContactPhone!.trim()
          : null,
      updatedAt: DateFormatFr.toIso(DateTime.now()),
    );

    await userRepository.updateUser(updated);
    notifyListeners();
    return updated;
  }

  /// Changes password after verifying the current password through [IdentityVerifier].
  Future<User> changePassword({
    required User currentUser,
    required String currentPassword,
    required String newPassword,
  }) async {
    final isOldPasswordValid =
        await identityVerifier.verify(currentUser, currentPassword);
    if (!isOldPasswordValid) {
      throw Exception(AppStrings.incorrectPassword);
    }

    final newSalt = PasswordHasher.generateSalt();
    final newPasswordHash = PasswordHasher.hashPassword(newPassword, newSalt);

    final updated = currentUser.copyWith(
      passwordHash: newPasswordHash,
      salt: newSalt,
      updatedAt: DateFormatFr.toIso(DateTime.now()),
    );

    await userRepository.updateUser(updated);
    notifyListeners();
    return updated;
  }
}
