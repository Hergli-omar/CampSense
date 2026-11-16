import 'package:sqflite/sqflite.dart';

/// Contrat abstrait pour le schéma de base de données d'un module.
/// Permet à chaque équipe de définir ses tables et migrations
/// de manière totalement isolée sans modifier le moteur SQLite central.
abstract class ModuleSchema {
  /// Nom du module (ex: 'user', 'event', 'marketplace', etc.)
  String get moduleName;

  /// Création initiale des tables du module.
  Future<void> onCreate(Database db);

  /// Migrations incrémentales du module lors d'un changement de version de la base.
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion);
}
