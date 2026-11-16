import '../../../core/utils/date_format_fr.dart';

/// Model representing a camping stay or bivouac session.
class Stay {
  final int? id;
  final int userId;
  final String placeName;
  final String startDate; // ISO 8601
  final String endDate; // ISO 8601
  final String? notes;

  const Stay({
    this.id,
    required this.userId,
    required this.placeName,
    required this.startDate,
    required this.endDate,
    this.notes,
  });

  DateTime get startDateTime => DateFormatFr.parseIso(startDate);
  DateTime get endDateTime => DateFormatFr.parseIso(endDate);

  /// French formatted date range (e.g. "18–20 juin 2027")
  String get dateRangeFr => DateFormatFr.formatRange(startDateTime, endDateTime);

  /// Whether this stay is in the future or ongoing
  bool get isUpcoming => DateFormatFr.isUpcoming(endDateTime);

  /// Converts Stay object to SQLite map.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'place_name': placeName,
      'start_date': startDate,
      'end_date': endDate,
      'notes': notes,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Factory from SQLite row map.
  factory Stay.fromMap(Map<String, dynamic> map) {
    return Stay(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      placeName: map['place_name'] as String,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      notes: map['notes'] as String?,
    );
  }

  /// Copy with overrides
  Stay copyWith({
    int? id,
    int? userId,
    String? placeName,
    String? startDate,
    String? endDate,
    String? notes,
  }) {
    return Stay(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      placeName: placeName ?? this.placeName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }
}
