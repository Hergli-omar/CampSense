import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/core/constants/admin_seed.dart';
import 'package:campsense/core/utils/password_hasher.dart';
import 'package:campsense/features/user/models/user.dart';
import 'package:campsense/features/user/services/admin_seeder.dart';
import 'test_helpers.dart';

void main() {
  group('AdminSeeder tests', () {
    late InMemoryUserRepository repository;

    setUp(() {
      repository = InMemoryUserRepository();
    });

    test('seedAdmin creates the unique admin account with hashed password', () async {
      final admin = await AdminSeeder.seedAdmin(repository);

      expect(admin.email, AdminSeed.email);
      expect(admin.fullName, AdminSeed.fullName);
      expect(admin.role, 'admin');
      expect(admin.experienceLevel, 'advanced');
      expect(admin.isAdmin, isTrue);

      // Verify password hashing
      expect(admin.passwordHash, isNot(equals(AdminSeed.password)));
      final isPasswordValid = PasswordHasher.verifyPassword(
        AdminSeed.password,
        admin.salt,
        admin.passwordHash,
      );
      expect(isPasswordValid, isTrue);
    });

    test('seedAdmin is idempotent: running multiple times does not create duplicates', () async {
      final first = await AdminSeeder.seedAdmin(repository);
      final second = await AdminSeeder.seedAdmin(repository);
      final third = await AdminSeeder.seedAdmin(repository);

      expect(first.id, equals(second.id));
      expect(second.id, equals(third.id));

      final allUsers = await repository.getAllUsers();
      // Admin should be excluded from regular user list
      expect(allUsers.where((u) => u.email == AdminSeed.email), isEmpty);

      final adminDirect = await repository.getUserByEmail(AdminSeed.email);
      expect(adminDirect, isNotNull);
    });

    test('seedAdmin does not overwrite or corrupt existing accounts', () async {
      // Pre-existing user
      final user = await repository.createUser(const User(
        fullName: 'Existing Camper',
        email: 'camper@campsense.com',
        passwordHash: 'somehash',
        salt: 'somesalt',
        role: 'camper',
        experienceLevel: 'beginner',
        createdAt: '2026-01-01T00:00:00.000',
        updatedAt: '2026-01-01T00:00:00.000',
      ));

      await AdminSeeder.seedAdmin(repository);

      final camperAfter = await repository.getUserById(user.id!);
      expect(camperAfter?.fullName, 'Existing Camper');
      expect(camperAfter?.email, 'camper@campsense.com');
    });
  });
}
