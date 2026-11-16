import 'package:flutter/foundation.dart';
import '../../../core/constants/admin_seed.dart';
import '../../../core/utils/date_format_fr.dart';
import '../../../core/utils/password_hasher.dart';
import '../data/user_repository.dart';
import '../models/stay.dart';
import '../models/user.dart';

/// Service responsible for idempotent provisioning of:
/// 1. The hardcoded Administrator account (in both DEBUG and RELEASE).
/// 2. Optional demo users (Noé Bernard & Azza Drissi) in DEBUG mode,
///    ensuring the admin member list is never empty during demonstration.
class AdminSeeder {
  /// Provisions the unique Administrator account idempotently.
  /// If the admin email already exists, no action is taken.
  static Future<User> seedAdmin(UserRepository repository) async {
    final existingAdmin = await repository.getUserByEmail(AdminSeed.email);
    if (existingAdmin != null) {
      return existingAdmin;
    }

    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hashPassword(AdminSeed.password, salt);
    final nowIso = DateFormatFr.toIso(DateTime.now());

    final adminUser = User(
      fullName: AdminSeed.fullName,
      email: AdminSeed.email,
      passwordHash: passwordHash,
      salt: salt,
      role: AdminSeed.role,
      experienceLevel: AdminSeed.experienceLevel,
      emergencyContactName: null,
      emergencyContactPhone: null,
      createdAt: nowIso,
      updatedAt: nowIso,
    );

    return await repository.createUser(adminUser);
  }

  /// Seeds demo users (Noé Bernard, Azza Drissi) in debug mode if not already present.
  static Future<void> seedDemoUsersIfMissing(UserRepository repository) async {
    if (!kDebugMode) return;

    try {
      // 1. Noé Bernard (Organisateur, Confirmé / Advanced)
      const noeEmail = 'noe.bernard@example.com';
      final existingNoe = await repository.getUserByEmail(noeEmail);
      if (existingNoe == null) {
        final salt = PasswordHasher.generateSalt();
        final passwordHash = PasswordHasher.hashPassword('Camp1234', salt);
        final now = DateTime.now();
        final joined = DateTime(now.year, now.month - 1, 5);

        final noe = User(
          fullName: 'Noé Bernard',
          email: noeEmail,
          passwordHash: passwordHash,
          salt: salt,
          role: 'organizer',
          experienceLevel: 'advanced',
          emergencyContactName: 'Claire Bernard',
          emergencyContactPhone: '06 11 22 33 44',
          createdAt: DateFormatFr.toIso(joined),
          updatedAt: DateFormatFr.toIso(now),
        );
        await repository.createUser(noe);
      }

      // 2. Azza Drissi (Campeur, Intermédiaire)
      const azzaEmail = 'azza.drissi@example.com';
      final existingAzza = await repository.getUserByEmail(azzaEmail);
      if (existingAzza == null) {
        final salt = PasswordHasher.generateSalt();
        final passwordHash = PasswordHasher.hashPassword('Camp1234', salt);
        final now = DateTime.now();
        final joined = DateTime(now.year, now.month - 2, 12);

        final azza = User(
          fullName: 'Azza Drissi',
          email: azzaEmail,
          passwordHash: passwordHash,
          salt: salt,
          role: 'camper',
          experienceLevel: 'intermediate',
          emergencyContactName: 'islem drissi',
          emergencyContactPhone: '06 00 00 00 27',
          createdAt: DateFormatFr.toIso(joined),
          updatedAt: DateFormatFr.toIso(now),
        );
        final createdAzza = await repository.createUser(azza);

        // Add 3 demo stays
        if (createdAzza.id != null) {
          await repository.addStay(Stay(
            userId: createdAzza.id!,
            placeName: 'Touzeur',
            startDate: '2027-06-18T00:00:00.000',
            endDate: '2027-06-20T23:59:59.000',
            notes: 'Bivouac dans les dunes du Sahara, météo sèche.',
          ));
          await repository.addStay(Stay(
            userId: createdAzza.id!,
            placeName: 'Bizerte',
            startDate: '2026-05-12T00:00:00.000',
            endDate: '2026-05-13T23:59:59.000',
            notes: 'Plage sauvage de Rafraf, feu de camp et brise marine.',
          ));
          await repository.addStay(Stay(
            userId: createdAzza.id!,
            placeName: 'Ain Drahem',
            startDate: '2026-04-23T00:00:00.000',
            endDate: '2026-04-24T23:59:59.000',
            notes: 'Forêt de chênes-lièges, nuit fraîche sous tente.',
          ));
        }
      }
    } catch (e) {
      debugPrint('AdminSeeder: error while seeding debug demo users: $e');
    }
  }

  /// Master seeding entry point to call at app launch.
  static Future<void> seedAll(UserRepository repository) async {
    await seedAdmin(repository);
    await seedDemoUsersIfMissing(repository);
  }
}
