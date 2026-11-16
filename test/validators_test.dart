import 'package:flutter_test/flutter_test.dart';
import 'package:campsense/core/constants/strings.dart';
import 'package:campsense/core/utils/validators.dart';

void main() {
  group('Validators tests', () {
    test('validateFullName requires at least 3 characters', () {
      expect(Validators.validateFullName(null), AppStrings.errNameTooShort);
      expect(Validators.validateFullName(''), AppStrings.errNameTooShort);
      expect(Validators.validateFullName('AB'), AppStrings.errNameTooShort);
      expect(Validators.validateFullName('   AB   '), AppStrings.errNameTooShort);
      expect(Validators.validateFullName('Ali'), isNull);
      expect(Validators.validateFullName('Azza Drissi'), isNull);
    });

    test('validateEmail validates RFC compliant email format', () {
      expect(Validators.validateEmail(null), AppStrings.errFieldRequired);
      expect(Validators.validateEmail(''), AppStrings.errFieldRequired);
      expect(Validators.validateEmail('invalid-email'), AppStrings.errInvalidEmail);
      expect(Validators.validateEmail('user@'), AppStrings.errInvalidEmail);
      expect(Validators.validateEmail('@domain.com'), AppStrings.errInvalidEmail);
      expect(Validators.validateEmail('azza.drissi@example.com'), isNull);
      expect(Validators.validateEmail('camper123@sub.domain.org'), isNull);
    });

    test('validatePassword requires at least 8 chars with letter and number', () {
      expect(Validators.validatePassword(null), AppStrings.errFieldRequired);
      expect(Validators.validatePassword(''), AppStrings.errFieldRequired);
      expect(Validators.validatePassword('short7'), AppStrings.errPasswordTooShort);
      expect(Validators.validatePassword('allcharacterswithoutdigits'), AppStrings.errPasswordTooShort);
      expect(Validators.validatePassword('1234567890'), AppStrings.errPasswordTooShort);
      expect(Validators.validatePassword('Camp1234'), isNull);
      expect(Validators.validatePassword('securePass99!'), isNull);
    });

    test('validateConfirmPassword ensures password match', () {
      expect(Validators.validateConfirmPassword(null, 'Pass1234'), AppStrings.errFieldRequired);
      expect(Validators.validateConfirmPassword('', 'Pass1234'), AppStrings.errFieldRequired);
      expect(Validators.validateConfirmPassword('Different1234', 'Pass1234'), AppStrings.errPasswordsDoNotMatch);
      expect(Validators.validateConfirmPassword('Pass1234', 'Pass1234'), isNull);
    });

    test('validatePhone handles optional and valid formats', () {
      expect(Validators.validatePhone(null), isNull);
      expect(Validators.validatePhone(''), isNull);
      expect(Validators.validatePhone('   '), isNull);
      expect(Validators.validatePhone('123'), AppStrings.errInvalidPhone);
      expect(Validators.validatePhone('abcdefghij'), AppStrings.errInvalidPhone);
      expect(Validators.validatePhone('06 00 00 00 27'), isNull);
      expect(Validators.validatePhone('+33 6 00 00 00 27'), isNull);
      expect(Validators.validatePhone('+216 20 123 456'), isNull);
    });

    test('evaluatePasswordStrength rates complexity properly', () {
      expect(Validators.evaluatePasswordStrength('short'), PasswordStrength.weak);
      expect(Validators.evaluatePasswordStrength('password1'), PasswordStrength.medium);
      expect(Validators.evaluatePasswordStrength('Str0ngP@ssw0rd!'), PasswordStrength.strong);
    });

    test('maskPhoneNumber masks all except last 2 digits', () {
      expect(Validators.maskPhoneNumber(null), '');
      expect(Validators.maskPhoneNumber(''), '');
      expect(Validators.maskPhoneNumber('06 00 00 00 27'), '•• •• •• 27');
      expect(Validators.maskPhoneNumber('12'), '12');
    });
  });
}
