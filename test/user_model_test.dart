import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/core/constants/strings.dart';
import 'package:campsense/features/user/models/stay.dart';
import 'package:campsense/features/user/models/user.dart';

void main() {
  group('User model tests', () {
    const testUser = User(
      id: 1,
      fullName: 'Azza Drissi',
      email: 'azza.drissi@example.com',
      passwordHash: 'dummyhash123',
      salt: 'dummysalt456',
      role: 'camper',
      experienceLevel: 'intermediate',
      emergencyContactName: 'islem drissi',
      emergencyContactPhone: '06 00 00 00 27',
      createdAt: '2026-08-12T10:00:00.000',
      updatedAt: '2026-10-28T12:00:00.000',
    );

    test('toMap converts all attributes properly for SQLite', () {
      final map = testUser.toMap();

      expect(map['id'], 1);
      expect(map['full_name'], 'Azza Drissi');
      expect(map['email'], 'azza.drissi@example.com');
      expect(map['password_hash'], 'dummyhash123');
      expect(map['salt'], 'dummysalt456');
      expect(map['role'], 'camper');
      expect(map['experience_level'], 'intermediate');
      expect(map['emergency_contact_name'], 'islem drissi');
      expect(map['emergency_contact_phone'], '06 00 00 00 27');
      expect(map['created_at'], '2026-08-12T10:00:00.000');
      expect(map['updated_at'], '2026-10-28T12:00:00.000');
    });

    test('fromMap restores User object faithfully from SQLite map', () {
      final map = testUser.toMap();
      final restored = User.fromMap(map);

      expect(restored.id, testUser.id);
      expect(restored.fullName, testUser.fullName);
      expect(restored.email, testUser.email);
      expect(restored.passwordHash, testUser.passwordHash);
      expect(restored.salt, testUser.salt);
      expect(restored.role, testUser.role);
      expect(restored.experienceLevel, testUser.experienceLevel);
      expect(restored.emergencyContactName, testUser.emergencyContactName);
      expect(restored.emergencyContactPhone, testUser.emergencyContactPhone);
      expect(restored.createdAt, testUser.createdAt);
      expect(restored.updatedAt, testUser.updatedAt);
    });

    test('initials generates correct uppercase 2-letter badge', () {
      expect(testUser.initials, 'AD');

      final singleName = testUser.copyWith(fullName: 'Camper');
      expect(singleName.initials, 'CA');

      final threeNames = testUser.copyWith(fullName: 'Jean Paul Sartre');
      expect(threeNames.initials, 'JP');
    });

    test('labels translate roles and experience levels to French', () {
      expect(testUser.roleLabelFr, AppStrings.roleCamper);
      expect(testUser.copyWith(role: 'organizer').roleLabelFr, AppStrings.roleOrganizer);

      expect(testUser.experienceLevelLabelFr, AppStrings.experienceIntermediate);
      expect(testUser.copyWith(experienceLevel: 'beginner').experienceLevelLabelFr, AppStrings.experienceBeginner);
      expect(testUser.copyWith(experienceLevel: 'advanced').experienceLevelLabelFr, AppStrings.experienceAdvanced);
    });

    test('copyWith updates specified fields only', () {
      final updated = testUser.copyWith(fullName: 'Azza Ben Drissi');
      expect(updated.fullName, 'Azza Ben Drissi');
      expect(updated.email, testUser.email);
      expect(updated.id, testUser.id);
    });
  });

  group('Stay model tests', () {
    const testStay = Stay(
      id: 10,
      userId: 1,
      placeName: 'Touzeur',
      startDate: '2027-06-18T00:00:00.000',
      endDate: '2027-06-20T23:59:59.000',
      notes: 'Bivouac dans les dunes',
    );

    test('Stay toMap and fromMap serialization', () {
      final map = testStay.toMap();
      expect(map['place_name'], 'Touzeur');
      expect(map['user_id'], 1);

      final restored = Stay.fromMap(map);
      expect(restored.id, testStay.id);
      expect(restored.placeName, testStay.placeName);
      expect(restored.notes, testStay.notes);
    });

    test('Stay French date formatting and upcoming calculation', () {
      expect(testStay.dateRangeFr, '18–20 juin 2027');
      expect(testStay.isUpcoming, isTrue);

      final pastStay = testStay.copyWith(
        startDate: '2020-01-01T00:00:00.000',
        endDate: '2020-01-03T00:00:00.000',
      );
      expect(pastStay.isUpcoming, isFalse);
    });
  });
}
