import 'package:campsense/features/user/data/user_repository.dart';
import 'package:campsense/features/user/models/stay.dart';
import 'package:campsense/features/user/models/user.dart';

/// In-memory implementation of [UserRepository] for fast, deterministic unit tests.
class InMemoryUserRepository implements UserRepository {
  final List<User> _users = [];
  final List<Stay> _stays = [];
  int _nextUserId = 1;
  int _nextStayId = 1;

  @override
  Future<User?> getUserById(int id) async {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final lower = email.trim().toLowerCase();
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == lower);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> createUser(User user) async {
    final created = user.copyWith(id: _nextUserId++);
    _users.add(created);
    return created;
  }

  @override
  Future<int> updateUser(User user) async {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx == -1) return 0;
    _users[idx] = user;
    return 1;
  }

  @override
  Future<int> deleteUser(int id) async {
    final countBefore = _users.length;
    _users.removeWhere((u) => u.id == id);
    _stays.removeWhere((s) => s.userId == id);
    return _users.length < countBefore ? 1 : 0;
  }

  @override
  Future<bool> emailExists(String email, {int? excludeUserId}) async {
    final lower = email.trim().toLowerCase();
    return _users.any((u) => u.email.toLowerCase() == lower && u.id != excludeUserId);
  }

  @override
  Future<List<Stay>> getStaysForUser(int userId) async {
    return _stays.where((s) => s.userId == userId).toList();
  }

  @override
  Future<Stay> addStay(Stay stay) async {
    final created = stay.copyWith(id: _nextStayId++);
    _stays.add(created);
    return created;
  }

  @override
  Future<int> deleteStay(int stayId) async {
    final countBefore = _stays.length;
    _stays.removeWhere((s) => s.id == stayId);
    return _stays.length < countBefore ? 1 : 0;
  }

  @override
  Future<int> getStaysCountForUser(int userId) async {
    return _stays.where((s) => s.userId == userId).length;
  }

  @override
  Future<List<User>> getAllUsers({String? query, String? role}) async {
    var result = _users.where((u) => u.role != 'admin').toList();

    if (role != null && role.isNotEmpty && role != 'all') {
      result = result.where((u) => u.role == role.toLowerCase()).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result
          .where((u) =>
              u.fullName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }

    result.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    return result;
  }

  @override
  Future<Map<String, int>> countByRole() async {
    final counts = {'camper': 0, 'organizer': 0};
    for (final u in _users) {
      if (u.role != 'admin' && counts.containsKey(u.role)) {
        counts[u.role] = counts[u.role]! + 1;
      }
    }
    return counts;
  }

  @override
  Future<User> createUserByAdmin(User user) async {
    if (user.role == 'admin') {
      throw const SecurityException('Cannot create admin account.');
    }
    return await createUser(user);
  }

  @override
  Future<int> updateUserByAdmin(User user) async {
    final existing = await getUserById(user.id!);
    if (existing != null && existing.isAdmin) {
      throw const SecurityException('Cannot update admin account.');
    }
    if (user.role == 'admin') {
      throw const SecurityException('Cannot promote to admin.');
    }
    return await updateUser(user);
  }

  @override
  Future<int> deleteUserByAdmin(int id) async {
    final target = await getUserById(id);
    if (target != null && target.isAdmin) {
      throw const SecurityException('Cannot delete admin account.');
    }
    return await deleteUser(id);
  }

  @override
  Future<int> getStayCount(int userId) async {
    return await getStaysCountForUser(userId);
  }
}
