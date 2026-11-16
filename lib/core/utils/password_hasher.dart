import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Utility class for hashing and verifying passwords using SHA-256 and secure random salts.
class PasswordHasher {
  PasswordHasher._();

  /// Generates a cryptographically secure random salt of the given byte length.
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Computes the SHA-256 hash of a password concatenated with the given salt.
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$password$salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies if the provided plain password and salt match the stored hash.
  static bool verifyPassword(String password, String salt, String expectedHash) {
    final computedHash = hashPassword(password, salt);
    return computedHash == expectedHash;
  }
}
