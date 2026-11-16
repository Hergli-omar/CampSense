import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../models/stay.dart';
import '../models/user.dart';
import 'user_repository.dart';

/// SQLite implementation of [UserRepository].
/// Isolated database layer: To migrate to Firebase or a REST API,
/// implement [UserRepository] with a `FirebaseUserRepository` and swap
/// the dependency injection in `lib/app.dart`.
class SqliteUserRepository implements UserRepository {
  final AppDatabase _dbManager;

  SqliteUserRepository([AppDatabase? dbManager])
      : _dbManager = dbManager ?? AppDatabase.instance;

  Future<Database> get _db async => await _dbManager.database;

  @override
  Future<User?> getUserById(int id) async {
    final db = await _db;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final db = await _db;
    final results = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  @override
  Future<User> createUser(User user) async {
    final db = await _db;
    final id = await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return user.copyWith(id: id);
  }

  @override
  Future<int> updateUser(User user) async {
    final db = await _db;
    if (user.id == null) {
      throw ArgumentError('Cannot update user without a primary ID.');
    }
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<int> deleteUser(int id) async {
    final db = await _db;
    // Foreign key ON DELETE CASCADE automatically removes stays in 'stays' table.
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> emailExists(String email, {int? excludeUserId}) async {
    final db = await _db;
    List<Map<String, dynamic>> results;
    if (excludeUserId != null) {
      results = await db.query(
        'users',
        columns: ['id'],
        where: 'LOWER(email) = ? AND id != ?',
        whereArgs: [email.trim().toLowerCase(), excludeUserId],
        limit: 1,
      );
    } else {
      results = await db.query(
        'users',
        columns: ['id'],
        where: 'LOWER(email) = ?',
        whereArgs: [email.trim().toLowerCase()],
        limit: 1,
      );
    }
    return results.isNotEmpty;
  }

  @override
  Future<List<Stay>> getStaysForUser(int userId) async {
    final db = await _db;
    final results = await db.query(
      'stays',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return results.map((map) => Stay.fromMap(map)).toList();
  }

  @override
  Future<Stay> addStay(Stay stay) async {
    final db = await _db;
    final id = await db.insert('stays', stay.toMap());
    return stay.copyWith(id: id);
  }

  @override
  Future<int> deleteStay(int stayId) async {
    final db = await _db;
    return await db.delete(
      'stays',
      where: 'id = ?',
      whereArgs: [stayId],
    );
  }

  @override
  Future<int> getStaysCountForUser(int userId) async {
    final db = await _db;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM stays WHERE user_id = ?',
      [userId],
    ));
    return count ?? 0;
  }

  @override
  Future<List<User>> getAllUsers({String? query, String? role}) async {
    final db = await _db;
    final whereClauses = <String>["role != 'admin'"];
    final whereArgs = <dynamic>[];

    if (role != null && role.isNotEmpty && role != 'all') {
      whereClauses.add('role = ?');
      whereArgs.add(role.toLowerCase());
    }

    if (query != null && query.trim().isNotEmpty) {
      final sanitized = '%${query.trim().toLowerCase()}%';
      whereClauses.add('(LOWER(full_name) LIKE ? OR LOWER(email) LIKE ?)');
      whereArgs.add(sanitized);
      whereArgs.add(sanitized);
    }

    final results = await db.query(
      'users',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'full_name COLLATE NOCASE ASC',
    );

    return results.map((map) => User.fromMap(map)).toList();
  }

  @override
  Future<Map<String, int>> countByRole() async {
    final db = await _db;
    final results = await db.rawQuery(
      "SELECT role, COUNT(*) as cnt FROM users WHERE role != 'admin' GROUP BY role",
    );
    final counts = <String, int>{
      'camper': 0,
      'organizer': 0,
    };
    for (final row in results) {
      final r = row['role'] as String?;
      final c = row['cnt'] as int? ?? 0;
      if (r != null && counts.containsKey(r)) {
        counts[r] = c;
      }
    }
    return counts;
  }

  @override
  Future<User> createUserByAdmin(User user) async {
    if (user.role == 'admin') {
      throw const SecurityException(
          'Cannot create admin account from administration screen.');
    }
    return await createUser(user);
  }

  @override
  Future<int> updateUserByAdmin(User user) async {
    if (user.id == null) {
      throw ArgumentError('Cannot update user without a primary ID.');
    }
    final existing = await getUserById(user.id!);
    if (existing != null && existing.isAdmin) {
      throw const SecurityException(
          'Cannot update an administrator account.');
    }
    if (user.role == 'admin') {
      throw const SecurityException(
          'Cannot promote an account to administrator.');
    }
    return await updateUser(user);
  }

  @override
  Future<int> deleteUserByAdmin(int id) async {
    final target = await getUserById(id);
    if (target == null) return 0;
    if (target.isAdmin) {
      throw const SecurityException(
          'Cannot delete an administrator account.');
    }
    return await deleteUser(id);
  }

  @override
  Future<int> getStayCount(int userId) async {
    return await getStaysCountForUser(userId);
  }
}
