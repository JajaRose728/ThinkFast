import 'package:flutter_test/flutter_test.dart';

import 'package:thinkfast/utils/helpers.dart';

void main() {
  group('validateInputForInjection', () {
    test('returns error for null/empty', () {
      expect(validateInputForInjection(null), 'This field cannot be empty');
      expect(validateInputForInjection(''), 'This field cannot be empty');
    });

    test('flags common SQL injection keyword patterns', () {
      expect(
        validateInputForInjection('1 UNION SELECT password FROM users'),
        'Invalid input: potentially harmful characters detected',
      );
    });

    test('flags common NoSQL injection patterns', () {
      expect(
        validateInputForInjection('{"\$where":"x"}'),
        'Invalid input: potentially harmful characters detected',
      );
    });

    test('allows safe input by default', () {
      expect(validateInputForInjection('Hello World 123!'), isNull);
    });

    test('flags basic XSS patterns when allowSpecialChars is false', () {
      expect(
        validateInputForInjection('<script>alert(1)</script>'),
        'Invalid input: potentially harmful content detected',
      );
    });
  });

  group('validateEmail', () {
    test('rejects null/empty', () {
      expect(validateEmail(null), 'Email cannot be empty');
      expect(validateEmail(''), 'Email cannot be empty');
    });

    test('rejects invalid email formats', () {
      expect(validateEmail('not-an-email'), 'Please enter a valid email address');
    });

    test('accepts a valid email', () {
      expect(validateEmail('user@example.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('rejects null/empty', () {
      expect(validatePassword(null), 'Password cannot be empty');
      expect(validatePassword(''), 'Password cannot be empty');
    });

    test('login mode: requires minimum length 6', () {
      expect(validatePassword('12345', isLogin: true), 'Password must be at least 6 characters');
      expect(validatePassword('123456', isLogin: true), isNull);
    });

    test('signup mode: requires minimum length 8 and character variety', () {
      expect(validatePassword('short1!', isLogin: false), 'Password must be at least 8 characters');

      expect(
        validatePassword('alllowercase1!', isLogin: false),
        'Password must contain at least one uppercase letter',
      );

      expect(
        validatePassword('ALLUPPERCASE1!', isLogin: false),
        'Password must contain at least one lowercase letter',
      );

      expect(
        validatePassword('NoNumberPassword!', isLogin: false),
        'Password must contain at least one number',
      );

      expect(
        validatePassword('NoSpecial1aB', isLogin: false),
        'Password must contain at least one special character',
      );
    });

    test('accepts a valid password in signup mode', () {
      expect(
        validatePassword('Valid1Password!', isLogin: false),
        isNull,
      );
    });
  });
}

