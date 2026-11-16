/// French date formatting utilities for stays, memberships, and displays.
class DateFormatFr {
  DateFormatFr._();

  static const List<String> _frenchMonths = [
    '',
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// Formats date range in elegant French style:
  /// e.g. "18–20 juin 2027" or "28 mai – 2 juin 2027"
  static String formatRange(DateTime start, DateTime end) {
    final startDay = start.day;
    final endDay = end.day;
    final startMonth = _frenchMonths[start.month];
    final endMonth = _frenchMonths[end.month];
    final startYear = start.year;
    final endYear = end.year;

    if (startYear == endYear && start.month == end.month) {
      if (startDay == endDay) {
        return '$startDay $startMonth $startYear';
      }
      return '$startDay–$endDay $startMonth $startYear';
    } else if (startYear == endYear) {
      return '$startDay $startMonth – $endDay $endMonth $startYear';
    } else {
      return '$startDay $startMonth $startYear – $endDay $endMonth $endYear';
    }
  }

  /// Formats a single date in French (e.g. "28 octobre 2026").
  static String formatSingleDate(DateTime date) {
    return '${date.day} ${_frenchMonths[date.month]} ${date.year}';
  }

  /// Formats date for membership tag (e.g. "12/2026" or "octobre 2026").
  static String formatMemberSince(DateTime date) {
    return '${_frenchMonths[date.month]} ${date.year}';
  }

  /// Formats a date in short French format: DD/MM/YYYY.
  static String formatShort(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// Parses an ISO 8601 string or returns fallback.
  static DateTime parseIso(String isoString) {
    return DateTime.tryParse(isoString) ?? DateTime.now();
  }

  /// Alias for parseIso.
  static DateTime fromIso(String isoString) => parseIso(isoString);

  /// Checks whether a stay is upcoming based on its end date and the current day.
  static bool isUpcoming(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final stayEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return !stayEnd.isBefore(today);
  }

  /// Formats DateTime into ISO 8601 string (UTC or local).
  static String toIso(DateTime date) => date.toIso8601String();
}
