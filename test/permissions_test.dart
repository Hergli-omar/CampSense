import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/features/user/models/user.dart';
import 'package:campsense/features/user/services/permissions.dart';

void main() {
  group('Permissions tests', () {
    const adminUser = User(
      id: 99,
      fullName: 'Omar (Administrateur)',
      email: 'omar@campsense.com',
      passwordHash: 'hash',
      salt: 'salt',
      role: 'admin',
      experienceLevel: 'advanced',
      createdAt: '2026-10-28T00:00:00.000',
      updatedAt: '2026-10-28T00:00:00.000',
    );

    const secondAdmin = User(
      id: 100,
      fullName: 'Autre Admin',
      email: 'autre@campsense.com',
      passwordHash: 'hash',
      salt: 'salt',
      role: 'admin',
      experienceLevel: 'advanced',
      createdAt: '2026-10-28T00:00:00.000',
      updatedAt: '2026-10-28T00:00:00.000',
    );

    const camperUser = User(
      id: 1,
      fullName: 'Azza Drissi',
      email: 'azza.drissi@example.com',
      passwordHash: 'hash',
      salt: 'salt',
      role: 'camper',
      experienceLevel: 'intermediate',
      createdAt: '2026-08-12T10:00:00.000',
      updatedAt: '2026-10-28T12:00:00.000',
    );

    const organizerUser = User(
      id: 2,
      fullName: 'Noé Bernard',
      email: 'noe.bernard@example.com',
      passwordHash: 'hash',
      salt: 'salt',
      role: 'organizer',
      experienceLevel: 'advanced',
      createdAt: '2026-09-01T10:00:00.000',
      updatedAt: '2026-10-28T12:00:00.000',
    );

    test('isAssignableRole strictly accepts camper and organizer, rejects admin', () {
      expect(Permissions.isAssignableRole('camper'), isTrue);
      expect(Permissions.isAssignableRole('organizer'), isTrue);
      expect(Permissions.isAssignableRole('admin'), isFalse);
      expect(Permissions.isAssignableRole('root'), isFalse);
      expect(Permissions.isAssignableRole('superadmin'), isFalse);
    });

    test('Admin area access requires admin role', () {
      expect(Permissions.canAccessAdminArea(adminUser), isTrue);
      expect(Permissions.canAccessAdminArea(camperUser), isFalse);
      expect(Permissions.canAccessAdminArea(organizerUser), isFalse);
      expect(Permissions.canAccessAdminArea(null), isFalse);
    });

    test('User list viewing is permitted only for admins', () {
      expect(Permissions.canViewUserList(adminUser), isTrue);
      expect(Permissions.canViewUserList(camperUser), isFalse);
      expect(Permissions.canViewUserList(organizerUser), isFalse);
    });

    test('Admin can create camper or organizer, but NEVER another admin', () {
      expect(Permissions.canCreateUser(adminUser, 'camper'), isTrue);
      expect(Permissions.canCreateUser(adminUser, 'organizer'), isTrue);
      expect(Permissions.canCreateUser(adminUser, 'admin'), isFalse);

      // Non-admins cannot create users through admin interface
      expect(Permissions.canCreateUser(camperUser, 'camper'), isFalse);
      expect(Permissions.canCreateUser(organizerUser, 'organizer'), isFalse);
    });

    test('Admin cannot update admin accounts (including their own via admin UI)', () {
      expect(Permissions.canUpdateUser(adminUser, camperUser), isTrue);
      expect(Permissions.canUpdateUser(adminUser, organizerUser), isTrue);
      expect(Permissions.canUpdateUser(adminUser, secondAdmin), isFalse);
      expect(Permissions.canUpdateUser(adminUser, adminUser), isFalse);
    });

    test('Admin cannot delete another admin or their own account', () {
      expect(Permissions.canDeleteUser(adminUser, camperUser), isTrue);
      expect(Permissions.canDeleteUser(adminUser, organizerUser), isTrue);
      expect(Permissions.canDeleteUser(adminUser, secondAdmin), isFalse);
      expect(Permissions.canDeleteUser(adminUser, adminUser), isFalse);
    });

    test('Regular users cannot delete or update another user account', () {
      expect(Permissions.canUpdateUser(camperUser, organizerUser), isFalse);
      expect(Permissions.canDeleteUser(camperUser, organizerUser), isFalse);

      // But can update/delete their own
      expect(Permissions.canUpdateUser(camperUser, camperUser), isTrue);
      expect(Permissions.canDeleteUser(camperUser, camperUser), isTrue);
    });
  });
}
