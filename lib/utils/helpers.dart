import 'dart:math';

String generateQuizCode() {
  return Random().nextInt(999999).toString().padLeft(6, '0');
}

// Input validation to prevent SQL/NoSQL injection patterns
String? validateInputForInjection(String? value, {bool allowSpecialChars = false}) {
  if (value == null || value.isEmpty) {
    return 'This field cannot be empty';
  }

  // Common SQL injection patterns
  final sqlInjectionPatterns = [
    RegExp(r'(\b(union|select|insert|delete|update|drop|create|alter|exec|execute)\b)', caseSensitive: false),
    RegExp("(--|#|/\\*|\\*/|;|'|\"|\\\\)"),
    RegExp(r'(\bor\b\s+\d+\s*=\s*\d+)', caseSensitive: false),
    RegExp(r'(\band\b\s+\d+\s*=\s*\d+)', caseSensitive: false),
  ];

  // Common NoSQL injection patterns
  final nosqlInjectionPatterns = [
    RegExp(r'(\$where|\$regex|\$ne|\$gt|\$lt|\$in|\$nin)', caseSensitive: false),
    RegExp(r'(\{.*\$.*\})'),
  ];

  for (final pattern in sqlInjectionPatterns) {
    if (pattern.hasMatch(value)) {
      return 'Invalid input: potentially harmful characters detected';
    }
  }

  for (final pattern in nosqlInjectionPatterns) {
    if (pattern.hasMatch(value)) {
      return 'Invalid input: potentially harmful characters detected';
    }
  }

  // If special chars are not allowed, check for basic XSS patterns
  if (!allowSpecialChars) {
    final xssPatterns = [
      RegExp(r'(<script|<iframe|<object|<embed)', caseSensitive: false),
      RegExp(r'(javascript:|vbscript:|data:)', caseSensitive: false),
    ];

    for (final pattern in xssPatterns) {
      if (pattern.hasMatch(value)) {
        return 'Invalid input: potentially harmful content detected';
      }
    }
  }

  return null; // Valid input
}

// Email validation with injection check
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email cannot be empty';
  }

  // Basic email regex
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }

  // Check for injection patterns
  return validateInputForInjection(value, allowSpecialChars: true);
}

// Password validation with injection check
String? validatePassword(String? value, {bool isLogin = false}) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  }

  if (isLogin) {
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
  } else {
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
  }

  // Check for injection patterns
  return validateInputForInjection(value, allowSpecialChars: true);
}