import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/features/user/data/user_repository.dart';
import 'package:campsense/features/user/models/user.dart';
import 'test_helpers.dart';

void main() {
  group('Admin user search, filter & role metrics tests', () {
    late InMemoryUserRepository repository;

    setUp(() async {
      repository = InMemoryUserRepository();

      // Seed 1 admin, 3 campers, 2 organizers
      await repository.createUser(const User(
        fullName: 'Omar (Administrateur)',
        email: 'omar@campsense.com',
        passwordHash: 'h',
        salt: 's',
        role: 'admin',
        experienceLevel: 'advanced',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));

      await repository.createUser(const User(
        fullName: 'Azza Drissi',
        email: 'azza.drissi@example.com',
        passwordHash: 'h',
        salt: 's',
        role: 'camper',
        experienceLevel: 'intermediate',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));

      await repository.createUser(const User(
        fullName: 'Bilel Ben Salah',
        email: 'bilel.bensalah@example.com',
        passwordHash: 'h',
        salt: 's',
        role: 'camper',
        experienceLevel: 'beginner',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));

      await repository.createUser(const User(
        fullName: 'Camille Martin',
        email: 'camille@example.com',
        passwordHash: 'h',
        salt: 's',
        role: 'camper',
        experienceLevel: 'advanced',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));

      await repository.createUser(const User(
        fullName: 'Noé Bernard',
        email: 'noe.bernard@example.com',
        passwordHash: 'h',
        salt: 's',
        role: 'organizer',
        experienceLevel: 'advanced',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));

      await repository.createUser(const User(
        fullName: 'Karim Guide',
        email: 'karim.guide@example.com',
        passwordHash: 'h',
        salt: 's',
        role: 'organizer',
        experienceLevel: 'intermediate',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));
    });

    test('getAllUsers strictly excludes admin accounts', () async {
      final list = await repository.getAllUsers();
      expect(list.length, 5); // 3 campers + 2 organizers
      expect(list.any((u) => u.role == 'admin'), isFalse);
      expect(list.any((u) => u.email == 'omar@campsense.com'), isFalse);
    });

    test('countByRole returns accurate counts for campers and organizers, excluding admin', () async {
      final counts = await repository.countByRole();
      expect(counts['camper'], 3);
      expect(counts['organizer'], 2);
      expect(counts.containsKey('admin'), isFalse);
    });

    test('Filter by role isolates campers and organizers correctly', () async {
      final campers = await repository.getAllUsers(role: 'camper');
      expect(campers.length, 3);
      expect(campers.every((u) => u.role == 'camper'), isTrue);

      final organizers = await repository.getAllUsers(role: 'organizer');
      expect(organizers.length, 2);
      expect(organizers.every((u) => u.role == 'organizer'), isTrue);
    });

    test('Search by name matches case-insensitively and partially', () async {
      final azza = await repository.getAllUsers(query: 'azza');
      expect(azza.length, 1);
      expect(azza.first.fullName, 'Azza Drissi');

      final ben = await repository.getAllUsers(query: 'BEN');
      expect(ben.length, 1);
      expect(ben.first.fullName, 'Bilel Ben Salah');
    });

    test('Search by email matches account', () async {
      final res = await repository.getAllUsers(query: 'noe.bernard');
      expect(res.length, 1);
      expect(res.first.email, 'noe.bernard@example.com');
      expect(res.first.role, 'organizer');
    });

    test('Combined search and role filter narrows results properly', () async {
      final res = await repository.getAllUsers(query: 'example.com', role: 'organizer');
      expect(res.length, 2);
      expect(res.every((u) => u.role == 'organizer'), isTrue);
    });

    test('Repository guards reject admin manipulation', () async {
      expect(
        () => repository.createUserByAdmin(const User(
          fullName: 'Fake Admin',
          email: 'fake@admin.com',
          passwordHash: 'h',
          salt: 's',
          role: 'admin',
          experienceLevel: 'advanced',
          createdAt: '2026-01-01',
          updatedAt: '2026-01-01',
        )),
        throwsA(isA<SecurityException>()),
      );
    });
  });
}
