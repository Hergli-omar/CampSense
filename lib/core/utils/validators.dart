import '../constants/strings.dart';

enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Form input validators for CampSense with French localized error messages.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates full name: must have at least 3 characters.
  static String? validateFullName(String? value) {
    if (value == null || value.trim().length < 3) {
      return AppStrings.errNameTooShort;
    }
    return null;
  }

  /// Validates email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errFieldRequired;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return AppStrings.errInvalidEmail;
    }
    return null;
  }

  /// Validates password: at least 8 chars, with at least 1 letter and 1 number.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errFieldRequired;
    }
    final hasMinLength = value.length >= 8;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);

    if (!hasMinLength || !hasLetter || !hasDigit) {
      return AppStrings.errPasswordTooShort;
    }
    return null;
  }

  /// Validates password confirmation.
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return AppStrings.errFieldRequired;
    }
    if (value != originalPassword) {
      return AppStrings.errPasswordsDoNotMatch;
    }
    return null;
  }

  /// Validates optional phone number: 8 to 15 digits, spaces and leading '+' permitted.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final cleaned = value.trim();
    // Allow optional '+' at start, then digits, spaces, and hyphens
    final validChars = RegExp(r'^\+?[0-9\s\-]+$');
    if (!validChars.hasMatch(cleaned)) {
      return AppStrings.errInvalidPhone;
    }
    // Count only digits
    final digitCount = cleaned.replaceAll(RegExp(r'\D'), '').length;
    if (digitCount < 8 || digitCount > 15) {
      return AppStrings.errInvalidPhone;
    }
    return null;
  }

  /// Calculates password strength: Weak, Medium, Strong.
  static PasswordStrength evaluatePasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;

    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    if (score < 3) {
      return PasswordStrength.weak;
    } else if (score < 5) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.strong;
    }
  }

  /// Formats phone number for display with security mask: e.g. "•• •• •• 27"
  static String maskPhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return '';
    }
    final clean = phone.trim();
    if (clean.length <= 2) return clean;
    final last2 = clean.substring(clean.length - 2);
    return '•• •• •• $last2';
  }
}
