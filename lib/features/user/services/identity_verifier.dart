import '../../../core/utils/password_hasher.dart';
import '../models/user.dart';

/// Extensible interface for identity verification.
///
/// NOTE FOR FUTURE BIOMETRIC EXTENSIONS:
/// You can implement additional verifiers such as `FingerprintIdentityVerifier`
/// or `FaceIdIdentityVerifier` that implement this same interface without
/// having to alter any UI screen or business service logic.
abstract class IdentityVerifier {
  /// Verifies identity for the given [user] using the provided [secret] (e.g. password, token).
  Future<bool> verify(User user, String? secret);
}

/// Password-based identity verification comparing SHA-256 hashed secret with user's salt.
class PasswordIdentityVerifier implements IdentityVerifier {
  const PasswordIdentityVerifier();

  @override
  Future<bool> verify(User user, String? secret) async {
    if (secret == null || secret.isEmpty) {
      return false;
    }
    return PasswordHasher.verifyPassword(secret, user.salt, user.passwordHash);
  }
}
