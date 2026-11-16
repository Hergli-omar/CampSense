import 'package:sqflite/sqflite.dart';
import '../../../core/database/module_schema.dart';

/// Schéma de base de données pour le module User.
///
/// Gère la création et les migrations des tables:
/// - `users`: comptes des campeurs, organisateurs et administrateur.
/// - `stays`: historique provisoire des séjours (en attendant le module Event).
///
/// NOTE:
/// Les tables des autres modules qui font référence à un utilisateur
/// doivent pointer vers `users(id)` avec la contrainte adaptée (ex: ON DELETE CASCADE).
class UserSchema implements ModuleSchema {
  @override
  String get moduleName => 'user';

  @override
  Future<void> onCreate(Database db) async {
    // 1. Table users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        role TEXT NOT NULL,
        experience_level TEXT NOT NULL,
        emergency_contact_name TEXT,
        emergency_contact_phone TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // 2. Table stays (historique séjours provisoire)
    await db.execute('''
      CREATE TABLE stays (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        place_name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        notes TEXT
      );
    ''');
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gérer ici les futures migrations propres aux tables users et stays
  }
}
