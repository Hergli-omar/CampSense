import '../../../core/constants/strings.dart';

/// User data model representing a registered camper or organizer.
class User {
  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;
  final String salt;
  final String role; // 'camper' | 'organizer'
  final String experienceLevel; // 'beginner' | 'intermediate' | 'advanced'
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String createdAt;
  final String updatedAt;

  const User({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.role,
    required this.experienceLevel,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this user account has administrator privileges.
  bool get isAdmin => role == 'admin';

  /// Human-friendly French role string
  String get roleLabelFr {
    switch (role) {
      case 'admin':
        return AppStrings.roleAdmin;
      case 'organizer':
        return AppStrings.roleOrganizer;
      case 'camper':
      default:
        return AppStrings.roleCamper;
    }
  }

  /// Human-friendly French experience string
  String get experienceLevelLabelFr {
    switch (experienceLevel) {
      case 'advanced':
        return AppStrings.experienceAdvanced;
      case 'intermediate':
        return AppStrings.experienceIntermediate;
      case 'beginner':
      default:
        return AppStrings.experienceBeginner;
    }
  }

  /// Initial letters for the avatar (e.g. "Azza Drissi" -> "AD")
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'CS';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Converts User object to a Map for SQLite storage.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'full_name': fullName,
      'email': email.trim().toLowerCase(),
      'password_hash': passwordHash,
      'salt': salt,
      'role': role,
      'experience_level': experienceLevel,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a User object from a SQLite row map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
      role: map['role'] as String,
      experienceLevel: map['experience_level'] as String,
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactPhone: map['emergency_contact_phone'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// Creates a copy of this User with optional field overrides.
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? passwordHash,
    String? salt,
    String? role,
    String? experienceLevel,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      role: role ?? this.role,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
