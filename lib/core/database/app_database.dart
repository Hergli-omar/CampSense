import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../features/user/data/user_schema.dart';
import '../utils/date_format_fr.dart';
import '../utils/password_hasher.dart';
import 'module_schema.dart';

// ============================================================================
// CONTRAT D'ÉQUIPE ET SCHÉMAS DE BASE DE DONNÉES SQLITE
// ============================================================================
// SEULE la personne responsable de l'intégration modifie la version (_dbVersion).
//
// Pour ajouter une table :
// 1) Créer le schéma du module (`<module>_schema.dart` qui implémente ModuleSchema).
// 2) L'ajouter à la liste `registeredSchemas` ci-dessous.
// 3) Incrémenter la version `_dbVersion`.
// 4) Gérer la migration dans le `onUpgrade` du schéma du module.
//
// LISTE DES PRÉFIXES DE TABLES PAR MODULE (pour éviter toute collision de noms) :
// - user        : `users`, `stays` (tables socle)
// - event       : `events_` (ex: `events_sorties`, `events_inscriptions`)
// - marketplace : `listings_` (ex: `listings_materiel`, `listings_messages`)
// - transport   : `trips_` (ex: `trips_trajets`, `trips_reservations`)
// - tutorial    : `guides_` (ex: `guides_tutoriels`, `guides_favoris`)
// - campsite    : `campsites_` (ex: `campsites_emplacements`, `campsites_avis`)
//
// IMPORTANT :
// Toutes les tables référençant un utilisateur doivent utiliser
// `user_id INTEGER NOT NULL REFERENCES users(id)`.
// `PRAGMA foreign_keys = ON;` est activé à chaque ouverture de la base.
// ============================================================================

/// Singleton SQLite database manager for CampSense.
/// Coordonne l'enregistrement des schémas des 6 modules.
class AppDatabase {
  static const String _dbName = 'campsense.db';

  /// Version courante de la base de données.
  /// MODIFIABLE UNIQUEMENT PAR LE RESPONSABLE D'INTÉGRATION.
  static const int _dbVersion = 1;

  /// Registre de tous les schémas de modules branchés sur l'application.
  static final List<ModuleSchema> registeredSchemas = [
    UserSchema(),
    // Exemples d'intégration future pour les autres modules :
    // EventSchema(),
    // MarketplaceSchema(),
    // TransportSchema(),
    // TutorialSchema(),
    // CampsiteSchema(),
  ];

  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enforce foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        for (final schema in registeredSchemas) {
          await schema.onCreate(db);
        }
        await _seedDemoData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (final schema in registeredSchemas) {
          await schema.onUpgrade(db, oldVersion, newVersion);
        }
      },
    );
  }

  /// Seeds initial demo user and stays requested for test validation:
  /// Azza Drissi, azza.drissi@example.com / Camp1234
  Future<void> _seedDemoData(Database db) async {
    try {
      final salt = PasswordHasher.generateSalt();
      final passwordHash = PasswordHasher.hashPassword('Camp1234', salt);
      final now = DateTime.now();
      final memberSince = DateTime(now.year, now.month - 2, 12);

      final userId = await db.insert('users', {
        'full_name': 'Azza Drissi',
        'email': 'azza.drissi@example.com',
        'password_hash': passwordHash,
        'salt': salt,
        'role': 'camper',
        'experience_level': 'intermediate',
        'emergency_contact_name': 'islem drissi',
        'emergency_contact_phone': '06 00 00 00 27',
        'created_at': DateFormatFr.toIso(memberSince),
        'updated_at': DateFormatFr.toIso(now),
      });

      // 3 demo stays:
      // 1. Touzeur (18–20 juin 2027) -> upcoming
      // 2. Bizerte (12–13 mai 2026) -> past
      // 3. Ain Drahem (23–24 avril 2026) -> past
      final stays = [
        {
          'user_id': userId,
          'place_name': 'Touzeur',
          'start_date': '2027-06-18T00:00:00.000',
          'end_date': '2027-06-20T23:59:59.000',
          'notes': 'Bivouac dans les dunes du Sahara, météo sèche.',
        },
        {
          'user_id': userId,
          'place_name': 'Bizerte',
          'start_date': '2026-05-12T00:00:00.000',
          'end_date': '2026-05-13T23:59:59.000',
          'notes': 'Plage sauvage de Rafraf, feu de camp et brise marine.',
        },
        {
          'user_id': userId,
          'place_name': 'Ain Drahem',
          'start_date': '2026-04-23T00:00:00.000',
          'end_date': '2026-04-24T23:59:59.000',
          'notes': 'Forêt de chênes-lièges, nuit fraîche sous tente.',
        },
      ];

      for (final stay in stays) {
        await db.insert('stays', stay);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error seeding demo data: $e');
      }
    }
  }

  /// Closes database connection (useful for resets and tests)
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
