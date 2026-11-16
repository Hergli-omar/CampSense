import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/core/utils/password_hasher.dart';

void main() {
  group('PasswordHasher tests', () {
    test('generateSalt generates random unique non-empty strings', () {
      final salt1 = PasswordHasher.generateSalt();
      final salt2 = PasswordHasher.generateSalt();

      expect(salt1.isNotEmpty, isTrue);
      expect(salt2.isNotEmpty, isTrue);
      expect(salt1, isNot(equals(salt2)));
    });

    test('different salts produce different hashes for identical passwords', () {
      const password = 'Camp1234Password!';
      final salt1 = PasswordHasher.generateSalt();
      final salt2 = PasswordHasher.generateSalt();

      final hash1 = PasswordHasher.hashPassword(password, salt1);
      final hash2 = PasswordHasher.hashPassword(password, salt2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('same password and salt produce deterministic identical hash', () {
      const password = 'Camp1234Password!';
      final salt = PasswordHasher.generateSalt();

      final hash1 = PasswordHasher.hashPassword(password, salt);
      final hash2 = PasswordHasher.hashPassword(password, salt);

      expect(hash1, equals(hash2));
    });

    test('verifyPassword returns true for matching password and false otherwise', () {
      const password = 'CorrectPassword123';
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hashPassword(password, salt);

      expect(PasswordHasher.verifyPassword(password, salt, hash), isTrue);
      expect(PasswordHasher.verifyPassword('WrongPassword123', salt, hash), isFalse);
      expect(PasswordHasher.verifyPassword('', salt, hash), isFalse);
    });
  });
}
